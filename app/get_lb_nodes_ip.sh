#!/usr/bin/env bash

set -e

cd ../terraform
IP_ADDR=$(terraform output -json lb_nodes_external_ip | jq -jc ".[][0][0]")

cd ../app
echo -n $IP_ADDR > config/ip_nodes.txt
