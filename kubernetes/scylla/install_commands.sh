#### !!!! https://operator.docs.scylladb.com/stable/helm.html !!!! ####

# create persistant volumes
mkdir /kube-data-scylla
kubectl apply -f scylla-pv.yaml

# create certificates
kubectl apply -f create-scylla-certs.yaml

helm repo add scylla http://192.168.122.100:8081/repository/scylla/
helm repo update


# prometheus
helm repo add prometheus-community http://192.168.122.100:8081/repository/prometheus-community
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack --values prometheus-values.yaml --create-namespace --namespace scylla-monitoring
# Scylla Service Monitor
kubectl apply -f scylla-service-monitor.yaml
# Scylla Manager Service Monitor
kubectl create namespace scylla-manager
kubectl apply -f scylla-manager-service-monitor.yaml
# download dashboards
wget https://github.com/scylladb/scylla-monitoring/archive/scylla-monitoring-3.6.0.tar.gz
tar -xvf scylla-monitoring-3.6.0.tar.gz
# install dashboards
kubectl -n scylla-monitoring create configmap scylla-dashboards --from-file=scylla-monitoring-scylla-monitoring-3.6.0/grafana/build/ver_4.3
kubectl -n scylla-monitoring patch configmap scylla-dashboards  -p '{"metadata":{"labels":{"grafana_dashboard": "1"}}}'
kubectl -n scylla-monitoring create configmap scylla-manager-dashboards --from-file=scylla-monitoring-scylla-monitoring-3.6.0/grafana/build/manager_2.2
kubectl -n scylla-monitoring patch configmap scylla-manager-dashboards  -p '{"metadata":{"labels":{"grafana_dashboard": "1"}}}'
# port forwarding
# kubectl -n scylla-monitoring port-forward deployment.apps/monitoring-grafana 3000
kubectl edit service/monitoring-grafana -n scylla-monitoring

kubectl delete servicemonitor/scylla-service-monitor -n scylla
helm upgrade --install scylla --namespace scylla scylla/scylla -f cluster-config.yaml
kubectl exec -it -n scylla -c scylla scylla-we-test-0 -- /bin/sh
cqlsh

# operator
helm install scylla-operator scylla/scylla-operator --values operator-config.yaml --namespace scylla-operator
# cluster
# edit validatingwebhookconfiguration to include secret name
helm install scylla scylla/scylla --values cluster-config.yaml --namespace scylla
# manager
kubectl apply -f scylla-manager-pv.yaml
helm install scylla-manager scylla/scylla-manager --values manager-config.yaml --create-namespace --namespace scylla-manager