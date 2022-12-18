resource "yandex_compute_instance_group" "ig-nodes" {
  name               = "ig-nodes"
  folder_id          = var.yandex_folder_id
  service_account_id = yandex_iam_service_account.ig-sa.id
  depends_on         = [yandex_resourcemanager_folder_iam_binding.editor]
  instance_template {
    platform_id = "standard-v3"
    name        = "node{instance.index}"
    hostname    = "node{instance.index}"
    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = var.ubuntu
        size     = 30
        type     = "network-ssd"
      }
    }

    network_interface {
      network_id = yandex_vpc_network.lab-net.id
      subnet_ids = ["${yandex_vpc_subnet.private-a.id}", "${yandex_vpc_subnet.private-b.id}", "${yandex_vpc_subnet.private-c.id}"]
      #      nat        = true
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.instance_nodes_count_map[terraform.workspace]
    }
  }

  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  load_balancer {
    target_group_name = "nodes-target-group-lb"
  }

}
