## !!!!!!! Guide: https://learn.hashicorp.com/tutorials/vault/kubernetes-cert-manager  !!!!!!! ## 

# PV erstellen
kubectl apply -f local-pv.yaml

# helm repo verbinden und vault installieren
helm repo add hashicorp http://192.168.122.100:8081/repository/hashicorp
helm repo update
helm install vault hashicorp/vault --set "injector.enabled=false"

# brauchen wir vermutlich nicht
# data-vault-0 pvc löschen
# kubectl apply -f vault-pvc.yaml

# vault entsperren
kubectl exec vault-0 -- vault operator init -key-shares=5 -key-threshold=3 -format=json > init-keys.json
cat init-keys.json | jq -r ".unseal_keys_b64[]"
kubectl exec vault-0 -- vault operator unseal #3x
kubectl exec vault-0 -- vault login $(cat init-keys.json | jq -r ".root_token")

# PKI einrichten
kubectl exec --stdin=true --tty=true vault-0 -- /bin/sh
vault secrets enable pki
vault secrets tune -max-lease-ttl=8760h pki
vault write pki/root/generate/internal common_name=example.com ttl=8760h
vault write pki/config/urls issuing_certificates="http://vault.default:8200/v1/pki/ca" crl_distribution_points="http://vault.default:8200/v1/pki/crl"
vault write pki/roles/example-dot-com allowed_domains=example.com allow_subdomains=true max_ttl=72h
vault policy write pki - <<EOF
path "pki*"                        { capabilities = ["read", "list"] }
path "pki/sign/example-dot-com"    { capabilities = ["create", "update"] }
path "pki/issue/example-dot-com"   { capabilities = ["create"] }
EOF
exit

# Kubernetes authentication Konfigurieren
kubectl exec --stdin=true --tty=true vault-0 -- /bin/sh
vault auth enable kubernetes

vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    issuer="https://kubernetes.default.svc.cluster.local"

vault write auth/kubernetes/role/issuer \
    bound_service_account_names=issuer \
    bound_service_account_namespaces=default \
    policies=pki \
    ttl=20m
exit

# Cert-Manager ausrollen
kubectl apply --validate=false -f cert-manager.crds.yaml
helm repo add http://192.168.122.100:8081/repository/jetstack/
helm repo update
kubectl apply -f cert-manager.crds.yaml
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.1

# Issuer konfigurieren
kubectl create serviceaccount issuer
ISSUER_SECRET_REF=$(kubectl get serviceaccount issuer -o json | jq -r ".secrets[].name")
kubectl apply -f vault-issuer.yaml
kubectl apply -f example-com-cert.yaml
