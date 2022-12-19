#!/usr/bin/env bash

set -e

count_cp=`terraform output -json cp_names | jq -c ".[] | length"`
count_nodes=`terraform output -json node_names | jq -c ".[] | length"`

printf "[all]\n"

for (( i=0; i<$count_cp; i++ ));
do
  terraform output -json cp_names | jq -j ".[][$i]"
  printf "   ansible_host="
  terraform output -json cp_ips | jq -j ".[][$i]"
  printf "\n"
done

for (( i=0; i<$count_nodes; i++ ));
do
  terraform output -json node_names | jq -j ".[][$i]"
  printf "   ansible_host="
  terraform output -json nodes_ips | jq -j ".[][$i]"
  printf "\n"
done

printf "\n[bastion]\n"
printf "bastion ansible_host="
terraform output -json bastion_external_ip | jq -jc ".[]"
printf " ansible_user=ubuntu\n"

printf "\n[all:vars]\n"
printf "ansible_user=ubuntu\n"
printf "supplementary_addresses_in_ssl_keys='"
terraform output -json lb_cp_external_ip | jq -cj ".[][0]"
printf "'\n\n"

printf "[kube_control_plane]\n"

for (( i=0; i<$count_cp; i++ ));
do
  terraform output -json cp_names | jq -j ".[][$i]"
  printf "\n"
done

printf "\n[etcd]\n"

for (( i=0; i<$count_cp; i++ ));
do
  terraform output -json cp_names | jq -j ".[][$i]"
  printf "\n"
done

printf "\n[kube_node]\n"

for (( i=0; i<$count_nodes; i++ ));
do
  terraform output -json node_names | jq -j ".[][$i]"
  printf "\n"
done

cat << EOF

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
EOF