#!/bin/bash

exe=$(realpath $0)
exedir=$(dirname $exe)


if [ ! -d $exedir/bin ]; then
    mkdir $exedir/bin
fi

# get yq yaml-parser
echo 'Pulling binary: yq'
OS=`cat assets/environment.yaml|grep ostype|sed 's/\(.*\)ostype: \(.*\)/\2/g'`
ARCH=`cat assets/environment.yaml|grep arch|sed 's/\(.*\)arch: \(.*\)/\2/g'`
wget -qO $exedir/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_$OS_$ARCH

# get rke2
echo 'Pulling binary: rke2'
source assets/gitrepos/shell-toolz/toolz_github.sh
VERSION=$(yq e .services.rke2.version assets/environment.yaml)

if [ "$VERSION" = "latest" ]; then
    VERSION=''      #empty = latest
fi

wget -qO $exedir/bin/rke2 $(GH_GetFileDownloadURL rancher/rke2 rke2.$OS-$ARCH $VERSION)
