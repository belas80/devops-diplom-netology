#!/usr/bin/env bash

set -e

bastion_ip=$(terraform output -json bastion_external_ip | jq -jc ".[0]")
cp1_ip=$(terraform output -json cp_ips | jq -jc ".[][0]")
lb_ip=$(terraform output -json lb_cp_external_ip | jq -jc ".[][0][0]")

ssh -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p ubuntu@$bastion_ip" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$cp1_ip "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/config

sed -i -- "s/127.0.0.1/$lb_ip/g" ~/.kube/config

chmod 600 ~/.kube/config
