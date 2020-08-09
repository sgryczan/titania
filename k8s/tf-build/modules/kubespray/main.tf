/*
* Create Kubespray Inventory File
*
*/

data "terraform_remote_state" "self" {
    backend = "s3"
    config = {
        region = "us-west-2"
        bucket = "${var.s3_bucket}"
        key = "${var.s3_key}"
    }
}


data "template_file" "inventory" {
  template = "${file("${path.module}/templates/inventory.tpl")}"

  vars = {
    connection_strings_master = "${join("\n",formatlist("%s ansible_host=%s ip=%s access_ip=%s",var.master_names, var.master_ips, var.master_ips, var.master_ips))}"
    connection_strings_node   = "${join("\n", formatlist("%s ansible_host=%s ip=%s access_ip=%s", var.worker_names, var.worker_ips, var.worker_ips, var.worker_ips))}"
    connection_strings_etcd   = "${join("\n",formatlist("%s ansible_host=%s ip=%s access_ip=%s", var.master_names, var.master_ips, var.master_ips, var.master_ips))}"
    list_master               = "${join("\n",var.master_names)}"
    list_node                 = "${join("\n",var.worker_names)}"
    list_etcd                 = "${join("\n",slice(concat(var.master_names, var.worker_names), 0, min(length(var.master_names) + length(var.worker_names), 3)))}"
    feature_gates             = "${length(var.feature_gates) == 0 ? "" : "kube_feature_gates=[${join(",",var.feature_gates)}]"}"
    vsphere_storage           = "${length(var.vsphere_storage) == 0 ? "" : "${join("\n",var.vsphere_storage)}"}"
  }
}

resource "local_file" "inventory" {
    content     = "${data.template_file.inventory.rendered}"
    filename = "${path.root}/inventory.ini"
}

data "template_file" "addons_yaml" {
  template = "${file("${path.module}/templates/addons.tpl")}"

  vars = {
    metrics_server_enabled = "${var.addons_metrics_server_enabled}"
    metrics_server_kubelet_insecure_tls = "${var.addons_metrics_server_kubelet_insecure_tls}"
    metrics_server_metric_resolution = "${var.addons_metrics_server_metric_resolution}"
    metrics_server_kubelet_preferred_address_types = "${var.addons_metrics_server_kubelet_preferred_address_types}"
  }
}

resource "local_file" "addons_yaml" {
    count = "${var.addons_metrics_server_enabled ? 1 : 0}"

    content     = "${data.template_file.addons_yaml.rendered}"
    filename = "${path.module}/pkg/inventory/sample/group_vars/k8s-cluster/addons.yml"
}

data "template_file" "group_vars_all_yaml" {
  template = "${file("${path.module}/templates/all.tpl")}"

  vars = {
    kubelet_node_config_extra_args = "${replace(yamlencode(var.kubelet_node_config_extra_args), "\"", "")}"
    kubelet_max_pods = "${var.kubelet_max_pods}"
    
    gcr_image_repo = var.kubespray_gcr_image_repo != "" ? format("%s: %s", "gcr_image_repo", var.kubespray_gcr_image_repo) : ""
    docker_image_repo = var.kubespray_docker_image_repo != "" ? format("%s: %s", "docker_image_repo", var.kubespray_docker_image_repo) : ""
    quay_image_repo = var.kubespray_quay_image_repo != "" ? format("%s: %s", "quay_image_repo", var.kubespray_quay_image_repo) : ""

    kubeadm_download_url = var.kubespray_kubeadm_download_url != "" ? format("%s: %s", "kubeadm_download_url", var.kubespray_kubeadm_download_url) : ""
    kubectl_download_url = var.kubespray_kubectl_download_url != "" ? format("%s: %s", "kubectl_download_url", var.kubespray_kubectl_download_url) : ""
    kubelet_download_url = var.kubespray_kubelet_download_url != "" ? format("%s: %s", "kubelet_download_url", var.kubespray_kubelet_download_url) : ""

    cni_download_url = var.kubespray_cni_download_url != "" ? format("%s: %s", "cni_download_url", var.kubespray_cni_download_url) : ""
    calicoctl_download_url = var.kubespray_calicoctl_download_url != "" ? format("%s: %s", "calicoctl_download_url", var.kubespray_calicoctl_download_url) : ""

    docker_rh_repo_base_url = var.kubespray_docker_rh_repo_base_url != "" ? format("%s: %s", "docker_rh_repo_base_url", var.kubespray_docker_rh_repo_base_url) : ""
    docker_rh_repo_gpgkey = var.kubespray_docker_rh_repo_gpgkey != "" ? format("%s: %s", "docker_rh_repo_gpgkey", var.kubespray_docker_rh_repo_gpgkey) : ""
  }
}

resource "local_file" "group_vars_all_yaml" {

    content     = "${data.template_file.group_vars_all_yaml.rendered}"
    filename = "${path.module}/pkg/inventory/sample/group_vars/all/all.yml"
}




locals {
  current_masters = "${length(lookup(data.terraform_remote_state.self.outputs, "master_ips", []))}"
  current_workers = "${length(lookup(data.terraform_remote_state.self.outputs, "worker_ips", []))}"
}



resource "null_resource" "ansible-spray" {
  provisioner "local-exec" {
    command = <<EOF
if [ -d ${path.root}/inventory/current ]; then
    rm -rf ${path.root}/inventory/current
fi
mkdir -p ${path.root}/inventory/current
cp -rfp ${path.module}/pkg/inventory/sample/* ${path.root}/inventory/current
mkdir ${path.root}/inventory/current/artifacts

# Using self-generated inventory
rm ${path.root}/inventory/current/inventory.ini
cp ${path.root}/inventory.ini ${path.root}/inventory/current/

# if using inventory builder
#declare -a IPS=(${join(" ",concat(var.master_ips, var.worker_ips))})
#CONFIG_FILE=${path.root}/inventory/current/hosts.yml python3 ${path.module}/pkg/contrib/inventory_builder/inventory.py $${IPS[@]}

#cat ${path.root}/inventory/current/hosts.yml
#cat ${path.root}/inventory/current/group_vars/all/all.yml
#cat ${path.root}/inventory/current/group_vars/k8s-cluster/k8s-cluster.yml

export PACKAGE_MGR="${var.package_manager}"


# Install sshpass and python3
# There are known issues with using sshpass with python2, so python3 may be needed in some cases (e.g Ubuntu)
ansible all \
        -b \
        -m ${var.package_manager} \
        -a "name=sshpass,python3 state=present" \
        -i ${path.root}/inventory/current/inventory.ini \
        -e ansible_user=${var.ansible_user} \
        -e ansible_password=${var.ansible_password} \
        -e ansible_sudo_password=${var.ansible_password} \
        #-e ansible_python_interpreter=/usr/bin/python3


# Assuming here that is the package manager is yum, then selinux is probably installed
if [ ${var.package_manager} == "yum" ]; then
    ansible all \
        -b \
        -m ${var.package_manager} \
        -a "name=libselinux-python state=present" \
        -i ${path.root}/inventory/current/inventory.ini \
        -e ansible_user=${var.ansible_user} \
        -e ansible_password=${var.ansible_password} \
        -e ansible_sudo_password=${var.ansible_password} \
        #-e ansible_python_interpreter=/usr/bin/python3
fi

# If the statefile for this project shows 0 masters, then we know that this is a new build
# and should run a fresh installation
if [[ ${local.current_masters} == 0 || ${var.force_build} == true ]] ; then
    ansible-playbook \
        -i ${path.root}/inventory/current/inventory.ini \
        ${path.module}/pkg/cluster.yml \
        -b \
        -e ansible_user=${var.ansible_user} \
        -e ansible_password=${var.ansible_password} \
        -e ansible_sudo_password=${var.ansible_password} \
        --flush-cache \
        #-e ansible_python_interpreter=/usr/bin/python3

# If the current number of masters or nodes is greater at runtime than what is in the statefile, then we need to scale
elif [[ (${local.current_masters} < ${length(var.master_ips)}) || (${local.current_workers} < ${length(var.worker_ips)}) ]] ; then
    ansible-playbook \
        -i ${path.root}/inventory/current/inventory.ini \
        ${path.module}/pkg/scale.yml \
        -b \
        -v \
        -e ansible_user=${var.ansible_user} \
        -e ansible_password=${var.ansible_password} \
        -e ansible_sudo_password=${var.ansible_password} \
       #-e ansible_python_interpreter=/usr/bin/python3
fi
EOF
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    template = "${data.template_file.inventory.rendered}"
    master_change = "${length(lookup(data.terraform_remote_state.self.outputs, "master_ips", []))}"
    worker_change = "${length(lookup(data.terraform_remote_state.self.outputs, "worker_ips", []))}"
    force = "${var.force_build}"
  }
}


// Copy Artifacts up to S3
resource "aws_s3_bucket_object" "kubeconfig" {
  bucket = "${var.s3_bucket}"
  key    = "${replace(var.s3_key, "terraform.tfstate", "kubeconfig")}"
  source = "${path.root}/inventory/current/artifacts/admin.conf"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  #etag = "${filemd5("${path.root}/inventory/artifacts/admin.conf")}"

  depends_on = [
    "null_resource.ansible-spray",
    "data.template_file.inventory"
  ]
}

resource "aws_s3_bucket_object" "ansible_inventory" {
  bucket = "${var.s3_bucket}"
  key    = "${replace(var.s3_key, "terraform.tfstate", "inventory/inventory.ini")}"
  source = "${path.root}/inventory/current/inventory.ini"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  #etag = "${filemd5("${path.root}/inventory/artifacts/admin.conf")}"

  depends_on = [
    "null_resource.ansible-spray",
    "data.template_file.inventory"
  ]
}

resource "aws_s3_bucket_object" "ansible_addons_yaml" {
  bucket = "${var.s3_bucket}"
  key    = "${replace(var.s3_key, "terraform.tfstate", "inventory/group_vars/addons.yaml")}"
  source = "${path.root}/inventory/current/group_vars/k8s-cluster/addons.yml"

  depends_on = [
    "null_resource.ansible-spray",
    "data.template_file.addons_yaml",
    "local_file.addons_yaml"
  ]
}

resource "aws_s3_bucket_object" "group_vars_all_yaml" {
  bucket = "${var.s3_bucket}"
  key    = "${replace(var.s3_key, "terraform.tfstate", "inventory/group_vars/addons.yaml")}"
  source = "${path.module}/pkg/inventory/sample/group_vars/all/all.yml"

  depends_on = [
    "null_resource.ansible-spray",
    "data.template_file.group_vars_all_yaml",
    "local_file.group_vars_all_yaml"
  ]
}

/* resource "aws_s3_bucket_object" "artifacts" {
  for_each = "${fileset(path.root, "inventory/**")}"

  bucket = "${var.s3_bucket}"
  key    = "${replace(var.s3_key, "terraform.tfstate", "${each.value}")}"
  source = "${path.root}/${each.value}"

  depends_on = [
    "null_resource.ansible-spray",
    "data.template_file.inventory"
  ]
} */
