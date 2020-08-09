terraform {
    required_version = ">= 0.13.0"
}

provider "aws" {
  region = "${var.s3_region}"
  alias = "k8s"
}

provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"
  alias = "k8s"
  
  # If using a self-signed cert
  allow_unverified_ssl = true
}

module "infra" {
    source =  "../modules/k8s-vm"

    providers = {
      vsphere = "vsphere.k8s"
    }
    vsphere_user                = "${var.vsphere_user}"
    vsphere_password            = "${var.vsphere_password}"
    vsphere_server              = "${var.vsphere_server}"

    num_masters                 = "${var.num_masters}"
    vm_name_prefix              = "${var.vm_name_prefix}"

    num_cpus                    = "${var.num_cpus}"
    memoryMB                    = "${var.memoryMB}"

    master_nodes_network_name   = var.master_nodes_network_name
    worker_node_networks        = var.worker_node_networks
    
    datastore_cluster_name      =  var.datastore_cluster_name

    // /${DATACENTER}/host/${CLUSTER}/Resources/${RESOURCE_POOL}
    resource_pool_name          = var.resource_pool_name
    folder                      = "${var.folder}/${var.vm_name_prefix}"
    datacenter_name             = var.datacenter_name
    vm_template_name            = var.vm_template_name
}

module "kubespray" {
  source = "../modules/kubespray"
  depends_on = [module.infra]
  providers = {
      aws = "aws.k8s"
  }
  
  s3_bucket = "${var.s3_bucket}"
  s3_key = var.s3_key
  
  ansible_user        = "${var.ansible_user}"
  ansible_password    = "${var.ansible_password}"

  package_manager = "yum"

  master_ips = "${module.infra.master_ips}"
  worker_ips = "${module.infra.worker_ips}"

  master_names        = "${module.infra.master_names}"
  worker_names        = "${module.infra.worker_names}"

  # Force a fresh kubespray build. 
  # i.e. machines were provisioned but ansible never ran for some reason
  # terraform apply -var 'kubespray_force_build=true'
  force_build         = "${var.kubespray_force_build}"

  # Addons
  addons_metrics_server_enabled = true
  addons_metrics_server_kubelet_insecure_tls = true
  addons_metrics_server_kubelet_preferred_address_types = "InternalIP,ExternalIP,Hostname"

  feature_gates = [
    "\"TTLAfterFinished=true\""
  ]

  vsphere_storage = [
    "cloud_provider=vsphere",
    "vsphere_vcenter_ip=${var.vsphere_server}",
    "vsphere_vcenter_port=443",
    "vsphere_insecure=1",
    "vsphere_user=${var.vsphere_user}",
    "vsphere_password=${var.vsphere_password}",
    "vsphere_datacenter=${var.datacenter_name}",
    "vsphere_datastore=${var.datastore_name}",
    "vsphere_working_dir=${var.folder}/${var.vm_name_prefix}",
    "vsphere_scsi_controller_type=pvscsi",
    "vsphere_resource_pool=${var.resource_pool_name}",
  ]

  kubespray_gcr_image_repo = var.kubespray_gcr_image_repo
  kubespray_docker_image_repo = var.kubespray_docker_image_repo
  kubespray_quay_image_repo = var.kubespray_quay_image_repo

  kubespray_kubeadm_download_url = var.kubespray_kubeadm_download_url
  kubespray_kubelet_download_url = var.kubespray_kubelet_download_url
  kubespray_kubectl_download_url = var.kubespray_kubectl_download_url

  kubespray_cni_download_url = var.kubespray_cni_download_url
  kubespray_calicoctl_download_url = var.kubespray_calicoctl_download_url

  kubespray_docker_rh_repo_base_url = var.kubespray_docker_rh_repo_base_url
  kubespray_docker_rh_repo_gpgkey = var.kubespray_docker_rh_repo_gpgkey
}

output "master_ips" {
  value = "${module.infra.master_ips}"
}

output "worker_ips" {
  value = "${module.infra.worker_ips}"
}

output "inventory" {
  value = "${module.kubespray.inventory}"
}