#!/bin/bash

# include toolbox for config manipulations
source $ASSETS/gitrepos/shell-toolz/toolz_configs.sh > >(tee -a /var/log/deployment/toolz.log) 2> >(tee -a /var/log/deployment/toolz.err >&2)

main() {
    case "${1}" in
        install-server)
            install;;
        install-agent)
            install-agent;;
    esac
    }

install-server() {
    mkdir -p /var/lib/rancher/rke2/agent/images
    chmod +x $ASSETS/bin/rke2-install.sh
    INSTALL_RKE2_ARTIFACT_PATH=$ASSETS/bin
    sh $ASSETS/bin/rke2-install.sh
    systemctl enable --now rke2-server.service
}

install-agent() {
    mkdir -p /var/lib/rancher/rke2/agent/images
    chmod +x $ASSETS/bin/rke2-install.sh
    INSTALL_RKE2_ARTIFACT_PATH=$ASSETS/bin
    INSTALL_RKE2_TYPE="agent"
    sh $ASSETS/bin/rke2-install.sh
}

main $@