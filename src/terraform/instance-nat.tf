resource "yandex_compute_instance" "instance-nat" {
  name                      = "nat"
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"
  hostname                  = "nat"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8josjq21d56924jfan"
      size     = 30
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.1.254"
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}