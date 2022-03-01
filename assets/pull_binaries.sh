#!/bin/bash

exe=$(realpath $0)
exedir=$(dirname $exe)


if [ ! -d $exedir/bin ]; then
    mkdir $exedir/bin
fi

# get yq yaml-parser
if [ ! -f $exedir/bin/yq ]; then
    echo 'Pulling binary: yq'
    OS=`cat $exedir/environment.yaml|grep ostype|sed 's/\(.*\)ostype: \(.*\)/\2/g'`
    ARCH=`cat $exedir/environment.yaml|grep arch|sed 's/\(.*\)arch: \(.*\)/\2/g'`
    wget -qO $exedir/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_$OS\_$ARCH
fi

# get rke2
if [ ! -f $exedir/bin/rke2-install.sh ]; then
    echo 'Pulling rke2 artifacts ...'
    source assets/gitrepos/shell-toolz/toolz_github.sh
    OS=$(yq e .env_common.ostype assets/environment.yaml)
    ARCH=$(yq e .env_common.arch assets/environment.yaml)
    RELEASE=$(yq e .services.rke2.release assets/environment.yaml)
    CNI=$(yq e .services.rke2.cni assets/environment.yaml)

    if [ "$RELEASE" = "latest" ]; then
        RELEASE=''      #empty = latest
    fi

    wget -qO $exedir/bin/rke2-images-$CNI.$OS-$ARCH.tar.gz $(GH_GetFileDownloadURL rancher/rke2 rke2-images-$CNI.$OS-$ARCH.tar.gz $RELEASE)
    wget -qO $exedir/bin/rke2.$OS-$ARCH.tar.gz $(GH_GetFileDownloadURL rancher/rke2 rke2.$OS-$ARCH.tar.gz $RELEASE)
    wget -qO $exedir/bin/sha256sum-$ARCH.txt $(GH_GetFileDownloadURL rancher/rke2 sha256sum-$ARCH.txt $RELEASE)
    wget -qO $exedir/bin/rke2-install.sh https://get.rke2.io
fi

# get SeaweedFS
if [ ! -f $exedir/bin/weed ]; then
    echo 'Pulling rke2 artifacts ...'
    source assets/gitrepos/shell-toolz/toolz_github.sh
    OS=$(yq e .env_common.ostype assets/environment.yaml)
    ARCH=$(yq e .env_common.arch assets/environment.yaml)
    RELEASE=$(yq e .services.seaweedfs.release assets/environment.yaml)

    if [ "$RELEASE" = "latest" ]; then
        RELEASE=''      #empty = latest
    fi

    wget -qO $exedir/bin/weed-$OS\_$ARCH.tar.gz $(GH_GetFileDownloadURL chrislusf/seaweedfs $OS\_$ARCH.tar.gz $RELEASE)
fi