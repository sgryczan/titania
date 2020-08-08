terraform {
  backend "s3" {
    region = "us-west-2"
    bucket = "netapp-sre-tf"
    key = "infra/k8s/hg-eldo/terraform.tfstate"
    #encrypt = true
  }
}

locals {
  s3_bucket             = "netapp-sre-tf"
  s3_project_key        = "hg-eldo"
  
  vm_name_prefix        = "hg-pxe"

  num_masters           = "3"

  num_cpus              = "2"
  memoryMB              = "2048"

  num_cpus_master       = "4"
  memoryMB_master       = "4096"
}


module "infra" {
    source =  "../modules/k8s-vm"

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
    folder                      = "${var.folder}/${local.vm_name_prefix}"
    datacenter_name             = var.datacenter_name
    vm_template_name            = var.vm_template_name
}

module "kubespray" {
  source = "../modules/kubespray"
  
  s3_bucket = "${local.s3_bucket}"
  s3_key = "infra/k8s/${local.s3_project_key == "" ? local.vm_name_prefix : local.s3_project_key}/terraform.tfstate"
  
  ansible_user        = "${local.ansible_user}"
  ansible_password    = "${local.ansible_password}"

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
    "vsphere_vcenter_ip=${local.vsphere_server}",
    "vsphere_vcenter_port=443",
    "vsphere_insecure=1",
    "vsphere_user=${local.vsphere_user}",
    "vsphere_password=${local.vsphere_password}",
    "vsphere_datacenter=${var.datacenter_name}",
    "vsphere_datastore=${var.datastore_name}",
    "vsphere_working_dir=${var.folder}/${local.vm_name_prefix}",
    "vsphere_scsi_controller_type=pvscsi",
    "vsphere_resource_pool=/NetApp-HCI-Datacenter-01/host/NetApp-HCI-Cluster-${local.environment == "Production" ? "01" : "02"}/Resources/ART:Appliance/SRE",
  ]
}

module "trident-nfs" {
  source = "../modules/trident-nfs"

  s3_bucket = "${local.s3_bucket}"
  s3_key = "infra/k8s/${local.s3_project_key == "" ? local.vm_name_prefix : local.s3_project_key}/terraform.tfstate"

  username          = "${local.trident_user}"
  password          = "${local.trident_password}"
  managementLIF     = "${local.trident_managementLIF}"
  dataLIF           = "${local.trident_dataLIF}"
  svm               = "${local.trident_svm}"

  ansible_user        = "${local.ansible_user}"
  ansible_password    = "${local.ansible_password}"

  inventory_file_contents = "${module.kubespray.inventory}"
  dependency = "${module.kubespray.inventory_object_key}"
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