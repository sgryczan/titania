variable "storage_driver_name" {
    default = "solidfire-san"
}

variable "username" {}

variable "password" {}

variable "svm" {}

variable "managementLIF" {}

variable "dataLIF" {}

variable "namespace" {
    default = "trident"
}

variable "kubeconfig" {
    default = ""
}