# Infra
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "num_masters" {}
variable "vm_name_prefix" {}
variable "num_cpus" {}
variable "memoryMB" {}
variable "master_nodes_network_name" {}
variable "worker_node_networks" {}
variable "datastore_cluster_name" {
    default = ""
}
variable "resource_pool_name" {}
variable "folder" {}
variable "datacenter_name" {}
variable "vm_template_name" {}

# Kubespray
variable "s3_bucket" {}
variable "s3_key" {}
variable "s3_region" {}
variable "ansible_user" {}
variable "ansible_password" {}
variable "package_manager" {
    default = "yum"
}

variable "datastore_name" {
  default = ""
}

# Trident
variable "kubespray_force_build" {}
variable "trident_user" {}
variable "trident_password" {}
variable "trident_managementLIF" {}
variable "trident_dataLIF" {}
variable "trident_svm" {}

variable "kubespray_gcr_image_repo" {
  default = ""
}

variable "kubespray_docker_image_repo" {
  default = ""
}

variable "kubespray_quay_image_repo" {
  default = ""
}

variable "kubespray_kubeadm_download_url" {
  default = ""
}

variable "kubespray_kubelet_download_url" {
  default = ""
}

variable "kubespray_kubectl_download_url" {
  default = ""
}

variable "kubespray_cni_download_url" {
  default = ""
}

variable "kubespray_calicoctl_download_url" {
  default = ""
}

variable "kubespray_docker_rh_repo_base_url" {
  default = ""
}

variable "kubespray_docker_rh_repo_gpgkey" {
  default = ""
}
