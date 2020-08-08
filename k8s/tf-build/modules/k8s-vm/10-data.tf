
locals {
  use_datastore_cluster = "${var.datastore_name == "" ? true : false}"
}

data "vsphere_datacenter" "dc" {
  name = "${var.datacenter_name}"
}

data "vsphere_datastore_cluster" "cluster" {
  count         = "${local.use_datastore_cluster ? 1 : 0}"
  name          = "${var.datastore_cluster_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "datastore" {
  count         = "${local.use_datastore_cluster ? 0 : 1}"
  name          = "${var.datastore_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.resource_pool_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "masters_network" {
  name          = "${var.master_nodes_network_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "workers_network" {
  count         =  length(var.worker_node_networks)
  name          = var.worker_node_networks[count.index]
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.vm_template_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
