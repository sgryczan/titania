data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vm_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

locals {
  num_addresses = length(var.static_ip_addresses)
}

data "template_file" "metadata" {
  count    = var.node_count
  template = file("${path.module}/cloudinit/templates/metadata.tpl")
  vars = {
    hostname = format("${var.vm_name}-${var.type}%02d", count.index + 1)
    netplan  = data.template_file.netplan[count.index].rendered
  }
}

data "template_file" "userdata" {
  count    = var.node_count
  template = file("${path.module}/cloudinit/kickstart-userdata.yaml")
  vars = {
    ssh_public_key          = tls_private_key.key.public_key_openssh
    admin_access_public_key = var.ssh_public_key
    netplan                 = base64encode(data.template_file.netplan[count.index].rendered)
    package_repo            = var.package_repo_url != "" ? data.template_file.repo_pkg.rendered : ""
    docker_repo             = var.docker_repo_url != "" ? data.template_file.repo_docker.rendered : ""
  }
}

data "template_file" "netplan" {
  count    = var.node_count
  template = file("${path.module}/cloudinit/templates/netplan.tpl")
  vars = {
    dhcp_enabled = local.num_addresses == 0
    dns_servers  = format("%s [%s]", "addresses:", join(",", var.dns_servers))
    addresses    = local.num_addresses > 0 ? format("%s %s", "addresses:", jsonencode([var.static_ip_addresses[count.index]])) : ""
    gateway      = var.default_gateway != "" ? format("%s %s", "gateway4:", var.default_gateway) : ""
  }
}

data "template_file" "repo_pkg" {
  template = file("${path.module}/cloudinit/templates/repo-pkg.tpl")
  vars = {
    package_repo_url = var.package_repo_url != "" ? var.package_repo_url : ""
  }
}

data "template_file" "repo_docker" {
  template = file("${path.module}/cloudinit/templates/repo-docker.tpl")
  vars = {
    docker_repo_url = var.docker_repo_url != "" ? var.docker_repo_url : ""
  }
}