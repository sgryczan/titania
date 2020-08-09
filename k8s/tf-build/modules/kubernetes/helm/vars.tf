variable "release_name" {
    type = string
    default = "nginx-ingress"
}

variable "chart" {
    type = string
    default = "nginx-ingress"
}

variable "repository_url" {
    type = string
    default = "https://kubernetes-charts.storage.googleapis.com"
}

variable "namespace" {
    type = string
    default = "ingress"
}

variable "create_namespace" {
    type = bool
    default = false
}

/* Example:
settings = [{
    version = "v0.15.0"
}] */

variable "settings" {
    type = list
    default = []
}

variable "wait" {
    type = bool
    default = true
}

variable "replace" {
    type = bool
    default = false
}