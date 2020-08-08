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