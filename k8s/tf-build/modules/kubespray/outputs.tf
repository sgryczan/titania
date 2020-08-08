output "inventory" {
  value = "${data.template_file.inventory.rendered}"
}

output "master_ips" {
  value = "${var.master_ips}"
}

output "master_names" {
  value = "${var.master_ips}"
}

output "worker_ips" {
  value = "${var.worker_ips}"
}

output "worker_names" {
  value = "${var.worker_names}"
}

output "inventory_object_key" {
  value = "${aws_s3_bucket_object.ansible_inventory.id}"
}

output "kubeconfig_object_key" {
  value = "${aws_s3_bucket_object.kubeconfig.id}"
}