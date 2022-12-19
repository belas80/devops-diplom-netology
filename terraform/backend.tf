terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "belas80-tf-states-netology"
    key                         = "main/terraform.tfstate"
    region                      = "ru-central1"
    profile                     = "netology"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}