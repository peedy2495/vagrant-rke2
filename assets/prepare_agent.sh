#!/bin/sh

mkdir -p /etc/rancher/rke2/

echo "server: https://$1:9345" >>/etc/rancher/rke2/config.yaml
echo "token: $2" >>/etc/rancher/rke2/config.yaml