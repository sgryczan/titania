package models

// Host represents a bootable host
// swagger:model
type Host struct {
	MacAddr string     `json:"macaddr"`
	Config  HostConfig `json:"config"`
}

// HostConfig stores boot params for hosts
// swagger:model
type HostConfig struct {
	// required: true
	// example: http://10.117.30.30/images/linux/CentOS-8.1.1911-x86_64-boot/isolinux/vmlinuz
	Kernel string `json:"kernel"`
	// required: true
	// example: ["http://10.117.30.30/images/linux/CentOS-8.1.1911-x86_64-boot/isolinux/initrd.img"]
	Initrd []string `json:"initrd"`
	// required: true
	// example: ip=dhcp inst.repo=http://repomirror-rtp.eng.netapp.com/centos/8/BaseOS/x86_64/os/ inst.ks=http://sf-artifactory.solidfire.net/artifactory/sre/boot/crux/centos8-callback.ks provisioner=pxe.sre.solidfire.net
	CmdLine string `json:"cmdline"`
}

// Inventory represents a collection of host MAC addresses
type Inventory struct {
	Count int      `json:"count"`
	Hosts []string `json:"hosts"`
}

// BootedHostsInventory represents a collection of events for a given host (MACAddr)
type BootedHostsInventory struct {
	MacAddr string         `json:"mac"`
	Events  []MachineEvent `json:"events"`
}

// MachineEvent represents a booted host
// swagger:model
type MachineEvent struct {
	// required: true
	// example: 1A:2B:3C:4D:5E:6F
	MacAddr string `json:"mac"`
	// required: true
	// example: iPXE
	Type string `json:"type"`
	// required: false
	// read only: true
	Date string `json:"date"`
	// example: {"macAddr": "1a:2b:3c:4d:5e:6f", "arch": "IA32"}
	Details interface{} `json:"details"`
}

// HostEventsRequest does things
type HostEventsRequest struct {
	// required: true
	// example: AA:BB:CC:DD:EE:FF
	MacAddr string `json:"mac"`
	// required: false
	// example: 5
	MaxHistory int `json:"max-history"`
}
