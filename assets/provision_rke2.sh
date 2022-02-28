#!/bin/bash

# include toolbox for config manipulations
source $ASSETS/gitrepos/shell-toolz/toolz_configs.sh > >(tee -a /var/log/deployment/toolz.log) 2> >(tee -a /var/log/deployment/toolz.err >&2)

