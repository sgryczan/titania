resource "vsphere_virtual_machine" "master" {
  count                     =  "${var.num_masters}"
  name                      = "${format("${var.vm_name_prefix}-master%02d", count.index + 1)}"
  resource_pool_id          = "${data.vsphere_resource_pool.pool.id}"
  datastore_id              = "${local.use_datastore_cluster ? null : data.vsphere_datastore.datastore.0.id}"
  datastore_cluster_id      = "${local.use_datastore_cluster ? data.vsphere_datastore_cluster.cluster.0.id : null}"
  folder                    = "${var.folder == "" ? null : vsphere_folder.folder.0.path}"

  num_cpus = "${var.num_cpus_master == "" ? var.num_cpus : var.num_cpus_master}"
  memory   = "${var.memoryMB_master == "" ? var.memoryMB : var.memoryMB_master}"

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
  guest_id  = "${data.vsphere_virtual_machine.template.guest_id}"

  network_interface {
    network_id   = "${data.vsphere_network.masters_network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }


  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  disk {
    label            = "disk1"
    size             = "100"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    unit_number      = 1
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "${format("${var.vm_name_prefix}-master%02d", count.index + 1)}"
        domain    = "one.den.solidfire.net"
      }

      network_interface {}
    }
  }

  lifecycle {
    ignore_changes = [
      "annotation",
      "boot_delay",
      "boot_retry_delay",
      "boot_retry_enabled",
      "cpu_hot_add_enabled",
      "cpu_hot_remove_enabled",
      "cpu_limit",
      "cpu_performance_counters_enabled",
      "cpu_reservation",
      "cpu_share_count",
      "custom_attributes",
      "efi_secure_boot_enabled",
      "enable_disk_uuid",
      "enable_logging",
      "extra_config",
      "memory_hot_add_enabled",
      "memory_limit",
      "memory_reservation",
      "nested_hv_enabled",
      "run_tools_scripts_before_guest_reboot",
      "sync_time_with_host",
      "tags",
      "clone",
    ]
  }
}


resource "vsphere_folder" "folder" {
  count = "${var.folder == "" ? 0 : 1}"
  path          = "${var.folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "worker" {
  count                     =  length(var.worker_node_networks)
  name                      = "${format("${var.vm_name_prefix}-worker%02d", count.index + 1)}"
  resource_pool_id          = "${data.vsphere_resource_pool.pool.id}"
  datastore_id              = "${local.use_datastore_cluster ? null : data.vsphere_datastore.datastore.0.id}"
  datastore_cluster_id      = "${local.use_datastore_cluster ? data.vsphere_datastore_cluster.cluster.0.id : null}"
  folder                    = "${var.folder == "" ? null : vsphere_folder.folder.0.path}"

  num_cpus = "${var.num_cpus}"
  memory   = "${var.memoryMB}"

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
  guest_id  = "${data.vsphere_virtual_machine.template.guest_id}"

  network_interface {
    network_id   = "${data.vsphere_network.workers_network[count.index].id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }


  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  disk {
    label            = "disk1"
    size             = "100"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    unit_number      = 1
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "${format("${var.vm_name_prefix}-worker%02d", count.index + 1)}"
        domain    = "one.den.solidfire.net"
      }

      network_interface {}
    }
  }

  lifecycle {
    ignore_changes = [
      "annotation",
      "boot_delay",
      "boot_retry_delay",
      "boot_retry_enabled",
      "cpu_hot_add_enabled",
      "cpu_hot_remove_enabled",
      "cpu_limit",
      "cpu_performance_counters_enabled",
      "cpu_reservation",
      "cpu_share_count",
      "custom_attributes",
      "efi_secure_boot_enabled",
      "enable_disk_uuid",
      "enable_logging",
      "extra_config",
      "memory_hot_add_enabled",
      "memory_limit",
      "memory_reservation",
      "nested_hv_enabled",
      "run_tools_scripts_before_guest_reboot",
      "sync_time_with_host",
      "tags",
      "clone",
    ]
  }
}