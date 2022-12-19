output "bastion_external_ip" {
  value = [yandex_compute_instance.instance-nat.network_interface[0].nat_ip_address]
}

output "cp_names" {
  value = [yandex_compute_instance_group.ig-cp.instances[*].name]
}

output "cp_ips" {
  value = [yandex_compute_instance_group.ig-cp.instances[*].network_interface[0].ip_address]
}

output "node_names" {
  value = [yandex_compute_instance_group.ig-nodes.instances[*].name]
}

output "nodes_ips" {
  value = [yandex_compute_instance_group.ig-nodes.instances[*].network_interface[0].ip_address]
}

output "lb_cp_external_ip" {
  value = [yandex_lb_network_load_balancer.cp-lb.listener[*].external_address_spec[*].address]
}

output "lb_nodes_external_ip" {
  value = [yandex_lb_network_load_balancer.nodes-lb.listener[*].external_address_spec[*].address]
}