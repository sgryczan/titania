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
