#!/bin/bash

EXE=$(realpath $0)
EXEDIR=$(dirname $EXE)

if [ ! -d $EXEDIR/bin ]; then
    mkdir $EXEDIR/bin
fi

OS=`cat $EXEDIR/environment.yaml|grep ostype|sed 's/\(.*\)ostype: \(.*\)/\2/g'`
ARCH=`cat $EXEDIR/environment.yaml|grep arch|sed 's/\(.*\)arch: \(.*\)/\2/g'`

# get yq yaml-parser
if [ ! -f $EXEDIR/bin/yq ]; then
    echo 'Pulling binary: yq'
    wget -O $EXEDIR/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_$OS\_$ARCH
fi

# get rke2
if [ ! -f $EXEDIR/bin/rke2-install.sh ]; then
    echo 'Pulling rke2 artifacts ...'
    source assets/gitrepos/shell-toolz/toolz_github.sh
    RELEASE=$(yq e .services.rke2.release assets/environment.yaml)
    CNI=$(yq e .services.rke2.cni assets/environment.yaml)

    if [ "$RELEASE" = "latest" ]; then
        RELEASE=''      #empty = latest
    fi

    wget -O $EXEDIR/bin/rke2-images-$CNI.$OS-$ARCH.tar.gz $(GH_GetFileDownloadURL rancher/rke2 rke2-images-$CNI.$OS-$ARCH.tar.gz $RELEASE)
    wget -O $EXEDIR/bin/rke2.$OS-$ARCH.tar.gz $(GH_GetFileDownloadURL rancher/rke2 rke2.$OS-$ARCH.tar.gz $RELEASE)
    wget -O $EXEDIR/bin/sha256sum-$ARCH.txt $(GH_GetFileDownloadURL rancher/rke2 sha256sum-$ARCH.txt $RELEASE)
    wget -O $EXEDIR/bin/rke2-install.sh https://get.rke2.io
fi

# get kubectl
if [ ! -f $EXEDIR/bin/kubectl ]; then
    echo 'Pulling binary: kubectl'
    STABLE=$(wget -qO- https://dl.k8s.io/release/stable.txt)
    wget -O $EXEDIR/bin/kubectl https://dl.k8s.io/release/$STABLE/bin/linux/amd64/kubectl
fi

# get SeaweedFS
if [ ! -f $EXEDIR/bin/weed-$OS\_$ARCH.tar.gz ]; then
    echo 'Pulling rke2 artifacts ...'
    source assets/gitrepos/shell-toolz/toolz_github.sh
    RELEASE=$(yq e .services.seaweedfs.release assets/environment.yaml)

    if [ "$RELEASE" = "latest" ]; then
        RELEASE=''      #empty = latest
    fi

    wget -O $EXEDIR/bin/weed-$OS\_$ARCH.tar.gz $(GH_GetFileDownloadURL chrislusf/seaweedfs $OS\_$ARCH.tar.gz $RELEASE)
fi