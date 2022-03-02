#!/bin/bash

EXE=$(realpath $0)
EXEDIR=$(dirname $EXE)

if [ ! -d $EXEDIR/certs ]; then
    mkdir $EXEDIR/certs
fi

if [ ! -f $EXEDIR/certs/id_rsa ]; then
    ssh-keygen -t rsa -P "" -f $EXEDIR/certs/id_rsa
fi