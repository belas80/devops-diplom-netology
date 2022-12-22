resource "yandex_compute_instance" "instance-test" {
  name                      = "test"
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"
  hostname                  = "test"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8j9i69vt27ujq6rqug"
      size     = 30
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.public.id
    nat            = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
