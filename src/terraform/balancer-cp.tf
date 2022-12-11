resource "yandex_lb_network_load_balancer" "cp-lb" {
  name = "cp-load-balancer"

  listener {
    name = "my-masters"
    port = 6443
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig-cp.load_balancer[0].target_group_id

    healthcheck {
      name                = "tcp"
      interval            = 5
      timeout             = 2
      healthy_threshold   = 3
      unhealthy_threshold = 3
      tcp_options {
        port = 6443
      }
    }
  }
}