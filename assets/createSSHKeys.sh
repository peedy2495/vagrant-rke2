#!/bin/bash

exe=$(realpath $0)
exedir=$(dirname $exe)

if [ ! -d $exedir/certs ]; then
    mkdir $exedir/certs
fi

if [ ! -f $exedir/certs/id_rsa ]; then
    ssh-keygen -t rsa -P "" -f $exedir/certs/id_rsa
fi