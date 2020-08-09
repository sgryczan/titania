output "master_ips" {
  value = "${vsphere_virtual_machine.master.*.default_ip_address}"
}

output "master_names" {
  value = "${vsphere_virtual_machine.master.*.name}"
}

output "worker_ips" {
  value = "${vsphere_virtual_machine.worker.*.default_ip_address}"
}

output "worker_names" {
  value = "${vsphere_virtual_machine.worker.*.name}"
}

output "master_nodes" {
  value = [
    for index, node in vsphere_virtual_machine.master :
    {
      name = node.name
      ip   = local.num_addresses == 0 ? node.default_ip_address : local.node_ips_no_mask[index]
    }
  ]
}

output "worker_nodes" {
  value = [
    for index, node in vsphere_virtual_machine.worker :
    {
      name = node.name
      ip   = local.num_addresses == 0 ? node.default_ip_address : local.node_ips_no_mask[index]
    }
  ]
}