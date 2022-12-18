resource "yandex_lb_network_load_balancer" "nodes-lb" {
  name = "nodes-load-balancer"

  listener {
    name        = "my-app"
    port        = 80
    target_port = 30000
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  listener {
    name        = "grafana"
    port        = 3000
    target_port = 30902
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  listener {
    name        = "atlantis"
    port        = 4141
    target_port = 30001
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig-nodes.load_balancer[0].target_group_id

    healthcheck {
      name                = "http"
      interval            = 5
      timeout             = 2
      healthy_threshold   = 3
      unhealthy_threshold = 3
      http_options {
        port = 8081
        path = "/healthz"
      }
    }
  }
}