variable "num_masters" {}

# Digits will be added automatically based on num_vms
# e.g. hci-ephem -> hci-ephem-001
variable "vm_name_prefix" {}

variable "num_cpus_master" {
  default = ""
}

variable "memoryMB_master" {
  default = ""
}

variable "num_cpus" {}

variable "memoryMB" {}

variable "datastore_cluster_name" {
  default = ""
}

variable "datastore_name" {
  default = ""
}

variable "datacenter_name" {}

variable "resource_pool_name" {
    default = "Resources"
}

variable "vm_template_name" {}

variable "folder" {
  default = ""
}

variable "vsphere_user" {}

variable "vsphere_password" {}


variable "vsphere_server" {}

variable "master_nodes_network_name" {}

variable "worker_node_networks" {
  type = "list"
  default = []
}
