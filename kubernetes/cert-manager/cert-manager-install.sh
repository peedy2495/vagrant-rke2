# Cert Manager installieren
kubectl apply --validate=false -f cert-manager.crds.yaml
helm repo add jetstack http://192.168.122.100:8081/repository/jetstack/
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.1

# root key und cert erstellen
openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 3650 -out rootCA.crt

# key und crt baes64 codiert speichern
cat rootCA.crt | base64 -w0


