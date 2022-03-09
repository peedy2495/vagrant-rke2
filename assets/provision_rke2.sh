#!/bin/bash

# include toolbox for network procedures
source $ASSETS/gitrepos/shell-toolz/toolz_network.sh > >(tee -a /var/log/deployment/toolz.log) 2> >(tee -a /var/log/deployment/toolz.err >&2)
source $ASSETS/gitrepos/shell-toolz/toolz_configs.sh > >(tee -a /var/log/deployment/toolz.log) 2> >(tee -a /var/log/deployment/toolz.err >&2)

main() {
    case "${1}" in
        install-server)
            install-server;;
        install-agent)
            install-agent;;
    esac
    }

install-server() {

    # use nexus registry proxy
    mkdir -p /etc/rancher/rke2
    cp $ASSETS/cfg/registries.yaml /etc/rancher/rke2/
    REPO_IP=$(yq e .services.nexus.ip $ASSETS/environment.yaml)
    DOCKERHUB=$(yq e .services.nexus.ports.dockerhub $ASSETS/environment.yaml)
    ReplVar REPO_IP /etc/rancher/rke2/registries.yaml
    ReplVar DOCKERHUB /etc/rancher/rke2/registries.yaml

    # install rke2
    mkdir -p /var/lib/rancher/rke2/agent/images
    chmod +x $ASSETS/bin/rke2-install.sh
    INSTALL_RKE2_ARTIFACT_PATH=$ASSETS/bin sh $ASSETS/bin/rke2-install.sh
    systemctl enable --now rke2-server.service

    ## setting up rke2 cluster
    SSHOPTS='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
    TOKEN=$(cat /var/lib/rancher/rke2/server/node-token)

    # catch all agents
    COUNT=0
    for node in $(yq e .nodes[].name? $ASSETS/environment.yaml); do
        WaitForHost $(yq e .nodes[$COUNT].name $ASSETS/environment.yaml) 22
        if [[ $(yq e .nodes[$COUNT].type $ASSETS/environment.yaml) = "agent" ]]; then
            ssh $SSHOPTS $(yq e .nodes[$COUNT].name $ASSETS/environment.yaml) "sh $ASSETS/prepare_agent.sh $HOSTNAME $TOKEN"
            ssh $SSHOPTS $(yq e .nodes[$COUNT].name $ASSETS/environment.yaml) "systemctl enable --now rke2-agent.service"
        fi
        ((COUNT++))
    done

    # install kubectl command
    install -v -b -m 750 -g root -t /usr/local/sbin $ASSETS/bin/kubectl
    echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml" >> /root/.bashrc

    # install helm command
    install -v -b -m 750 -g root -t /usr/local/sbin $ASSETS/bin/helm
    #helm init
}

install-agent() {
    
    # use nexus registry proxy
    mkdir -p /etc/rancher/rke2
    cp $ASSETS/cfg/registries.yaml /etc/rancher/rke2/
    REPO_IP=$(yq e .services.nexus.ip $ASSETS/environment.yaml)
    DOCKERHUB=$(yq e .services.nexus.ports.dockerhub $ASSETS/environment.yaml)
    ReplVar REPO_IP /etc/rancher/rke2/registries.yaml
    ReplVar DOCKERHUB /etc/rancher/rke2/registries.yaml

    # install rke2
    mkdir -p /var/lib/rancher/rke2/agent/images
    chmod +x $ASSETS/bin/rke2-install.sh
    export INSTALL_RKE2_TYPE="agent"
    INSTALL_RKE2_ARTIFACT_PATH=$ASSETS/bin sh $ASSETS/bin/rke2-install.sh
}

main $@