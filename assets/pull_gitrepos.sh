#!/bin/bash

EXE=$(realpath $0)
EXEDIR=$(dirname $EXE)

if [ ! -d $EXEDIR/gitrepos ]; then
    mkdir $EXEDIR/gitrepos
fi

git clone https://github.com/peedy2495/shell-toolz.git $EXEDIR/gitrepos/shell-toolz 2>/dev/null