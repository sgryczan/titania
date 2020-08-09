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

