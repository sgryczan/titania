locals {
  deliverables_path  = var.deliverables_path == "" ? "./deliverables" : var.deliverables_path
}

terraform {
  required_providers {
    rke = {
      source = "rancher/rke"
      version = "1.0.1"
    }
  }
}

resource "rke_cluster" "cluster" {
  # 2 minute timeout specifically for rke-network-plugin-deploy-job but will apply to any addons
  addon_job_timeout = 120
  dynamic "nodes" {
    for_each = [for node in var.master_nodes : {
      name = node["name"]
      ip   = node["ip"]
    }]
    content {
      address           = nodes.value.ip
      hostname_override = nodes.value.name
      user              = var.ssh_user
      role              = ["controlplane", "etcd"]
      ssh_key           = var.ssh_private_key
    }
  }

  dynamic "nodes" {
    for_each = [for node in var.worker_nodes : {
      name = node["name"]
      ip   = node["ip"]
    }]
    content {
      address           = nodes.value.ip
      hostname_override = nodes.value.name
      user              = var.ssh_user
      role              = ["worker"]
      ssh_key           = var.ssh_private_key
    }
  }
}

resource "local_file" "kubeconfig" {
  filename = format("${local.deliverables_path}/kubeconfig")
  content  = rke_cluster.cluster.kube_config_yaml
}

resource "local_file" "rkeconfig" {
  filename = format("${local.deliverables_path}/rkeconfig.yaml")
  content  = rke_cluster.cluster.rke_cluster_yaml
}
