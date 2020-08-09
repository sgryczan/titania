variable "worker_ips" {
  type = "list"
}

variable "master_ips" {
  type = "list"
}

variable "master_names" {
  type = "list"
}

variable "worker_names" {
  type = "list"
}


variable "inventory_file" {
  default = "~/inventory.ini"
}

variable "ansible_user" {
    default = ""
}

variable "ansible_password" {
    default = ""
}


variable "package_manager" {
  description = "package manager on target OS (yum, apt)"
  default = "apt"
}

variable "s3_bucket" {
  description = "name of s3 bucket containing project statefile"
  default = "netapp-sre-tf"
}

variable "s3_key" {
  description = "path to s3 statefile"
  default = "infra/k8s/dev-rtp-piglet/terraform.tfstate"
}

variable "s3_region" {
  description = "region of s3 bucket"
  default = "us-west-2"
}


variable "addons_metrics_server_enabled" {
  default = false
}

variable "addons_metrics_server_kubelet_insecure_tls" {
  default = true
}

variable "addons_metrics_server_metric_resolution" {
  default = "60s"
}

variable "addons_metrics_server_kubelet_preferred_address_types" {
  default = "InternalIP"
}

variable "feature_gates" {
  type = "list"
  default = []
}

variable "vsphere_storage" {
  type = "list"
  default = []
}

variable "force_build" {
    default = false
}


# Docs: https://github.com/kubernetes-sigs/kubespray/blob/master/docs/vars.md#custom-flags-for-kube-components
# Field definitions: https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/kubelet/config/v1beta1/types.go#L350-L368
variable "kubelet_node_config_extra_args" {
  type = "map"
  default = {
    "kubelet_node_config_extra_args": {
      "imageGCHighThresholdPercent": "65"
      "imageGCLowThresholdPercent": "50"
    }
  }
}

variable "kubelet_max_pods" {
  default = 110
}


variable "kubespray_gcr_image_repo" {
  default = ""
}

variable "kubespray_docker_image_repo" {
  default = ""
}

variable "kubespray_quay_image_repo" {
  default = ""
}

variable "kubespray_kubeadm_download_url" {
  default = ""
}

variable "kubespray_kubelet_download_url" {
  default = ""
}

variable "kubespray_kubectl_download_url" {
  default = ""
}

variable "kubespray_cni_download_url" {
  default = ""
}

variable "kubespray_calicoctl_download_url" {
  default = ""
}

variable "kubespray_docker_rh_repo_base_url" {
  default = ""
}

variable "kubespray_docker_rh_repo_gpgkey" {
  default = ""
}

