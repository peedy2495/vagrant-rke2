#!/bin/bash

# include toolbox for network procedures
source $ASSETS/gitrepos/shell-toolz/toolz_network.sh > >(tee -a /var/log/deployment/toolz.log) 2> >(tee -a /var/log/deployment/toolz.err >&2)

main() {
    case "${1}" in
        install-server)
            install-server;;
        install-agent)
            install-agent;;
    esac
    }

install-server() {
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
}

install-agent() {
    mkdir -p /var/lib/rancher/rke2/agent/images
    chmod +x $ASSETS/bin/rke2-install.sh
    export INSTALL_RKE2_TYPE="agent"
    INSTALL_RKE2_ARTIFACT_PATH=$ASSETS/bin sh $ASSETS/bin/rke2-install.sh
}

main $@