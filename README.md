# vagrant-RKE2
Deploy Kubernetes RKE2 Cluster with seaweedfs

Working:
- basic deployment with current upgrades via external Nexus3 apt proxy
- paswordless ssh vice versa for root
- rke2 deployment with one server and multiple agents
- automatic join of known agents
- kubectl @ server

2Do:
- use Nexus3 as container registry (proxy)
- SeaweedFS deployment for persistent volumes
- use external HA-database for rke2 via galera and haproxy
- multiple servers for HA