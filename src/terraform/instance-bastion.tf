#resource "yandex_compute_instance" "instance-cp1" {
#  name                      = "instance-cp1"
#  platform_id               = "standard-v3"
#  zone                      = "ru-central1-a"
#  hostname                  = "cp1"
#  allow_stopping_for_update = true
#
#  resources {
#    cores  = 2
#    memory = 2
#  }
#
#  boot_disk {
#    initialize_params {
#      image_id = var.ubuntu
#      size     = 30
#      type     = "network-ssd"
#    }
#  }
#
#  network_interface {
#    subnet_id      = yandex_vpc_subnet.private-a.id
#    nat            = true
#    nat_ip_address = "51.250.70.183"
#  }
#
#  metadata = {
#    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#  }
#}