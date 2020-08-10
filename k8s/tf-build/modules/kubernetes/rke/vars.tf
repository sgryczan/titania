variable "ssh_private_key" {
  type        = string
  description = "SSH private key"
}

variable "ssh_user" {
  type = string
  default = "ubuntu"
}

variable "deliverables_path" {
  type        = string
  description = "Path to deliverables directory"
  default     = "./deliverables"
}

variable "master_nodes" {
  type    = list
  default = []
}

variable "worker_nodes" {
  type    = list
  default = []
}


/* Example: 

private_registries = [{
  url = "my.registry.com"
  is_default  = true
}] 

*/

variable "private_registries" {
  type = list
  default = []
}

variable "network_plugin" {
  type = string
  default = "canal"
}

variable "kube_controller_extra_args" {
  type = map
  default = {
    "cluster-signing-cert-file" = "/etc/kubernetes/ssl/kube-ca.pem"
    "cluster-signing-key-file" = "/etc/kubernetes/ssl/kube-ca-key.pem"
  }
}