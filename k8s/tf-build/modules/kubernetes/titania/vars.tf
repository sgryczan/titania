variable "image_name_boot" {
    type = string
    default = "sgryczan/titania-boot"
}

variable "image_name_api" {
    type = string
    default = "sgryczan/titania-api"
}

variable "image_tag" {
    type = string
    description = "Image tag to use (latest)"
    default = "latest"
}

variable "namespace" {
    type = string
    description = "Namespace to deploy into"
    default = "titania"
}

variable "hostname" {
    type = string
    description = "Ingress hostname"
}

variable "create_namespace" {
    type = bool
    default = false
}

variable "http_port" {
    type = string
    default = 80
}

