# Network
resource "yandex_vpc_network" "lab-net" {
  name = "lab-network"
}

# Private subnet a
resource "yandex_vpc_subnet" "private-a" {
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-a"
  name           = "private-a"
  network_id     = yandex_vpc_network.lab-net.id
}

# Private subnet b
resource "yandex_vpc_subnet" "private-b" {
  v4_cidr_blocks = ["192.168.21.0/24"]
  zone           = "ru-central1-b"
  name           = "private-b"
  network_id     = yandex_vpc_network.lab-net.id
}

# Private subnet c
resource "yandex_vpc_subnet" "private-c" {
  v4_cidr_blocks = ["192.168.22.0/24"]
  zone           = "ru-central1-c"
  name           = "private-c"
  network_id     = yandex_vpc_network.lab-net.id
}
