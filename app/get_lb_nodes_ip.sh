#!/usr/bin/env bash

set -e

cd ../terraform
echo $(terraform output -json lb_nodes_external_ip | jq -jc ".[][0][0]")
