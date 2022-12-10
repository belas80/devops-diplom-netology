variable "yandex_cloud_id" {
  default = "b1gmh5fl71a23gh6qrqc"
}

variable "yandex_folder_id" {
  default = "b1g9eq93ionckal26dpc"
}

variable "ubuntu" {
  default = "fd8kdq6d0p8sij7h5qe3"
}

variable "instance_nodes_count_map" {
  type = map(number)
  default = {
    stage = 2
    prod  = 3
  }
}

variable "instance_cp_count_map" {
  type = map(number)
  default = {
    stage = 1
    prod  = 3
  }
}