#output "external_ip_cp" {
#  value = [yandex_compute_instance.instance-cp1.network_interface[0].nat_ip_address]
#}

output "cp_names" {
  value = [yandex_compute_instance_group.ig-cp.instances[*].name]
}

output "cp_external_ip" {
  value = [yandex_compute_instance_group.ig-cp.instances[*].network_interface[0].nat_ip_address]
}

output "node_names" {
  value = [yandex_compute_instance_group.ig-nodes.instances[*].name]
}

output "nodes_external_ip" {
  value = [yandex_compute_instance_group.ig-nodes.instances[*].network_interface[0].nat_ip_address]
}