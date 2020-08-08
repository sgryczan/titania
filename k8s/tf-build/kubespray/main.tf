terraform {
    required_version = ">= 0.13.0"
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
    folder                      = "${var.folder}/${var.vm_name_prefix}"
    datacenter_name             = var.datacenter_name
    vm_template_name            = var.vm_template_name
}

module "kubespray" {
  source = "../modules/kubespray"
  depends_on = [module.infra]
  
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
}

module "trident-nfs" {
  source = "../modules/trident-nfs"
  depends_on = [module.kubespray]

  s3_bucket = "${var.s3_bucket}"
  s3_key = "${var.s3_key}"

  username          = "${var.trident_user}"
  password          = "${var.trident_password}"
  managementLIF     = "${var.trident_managementLIF}"
  dataLIF           = "${var.trident_dataLIF}"
  svm               = "${var.trident_svm}"

  ansible_user        = "${var.ansible_user}"
  ansible_password    = "${var.ansible_password}"

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