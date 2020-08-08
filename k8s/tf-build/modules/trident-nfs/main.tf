data "template_file" "trident_config" {
    template = "${file("${path.module}/templates/basic.tpl")}"

    vars = {
        managementLIF = "${var.managementLIF}"
        dataLIF       = "${var.dataLIF}"
        svm           = "${var.svm}"
        username      = "${var.username}"
        password      = "${var.password}"
    }
}


resource "local_file" "backend_config" {
    content = data.template_file.trident_config.rendered
    filename = "${path.root}/trident_backends.json"
}

resource "local_file" "ansible_inventory" {
    content = "${var.inventory_file_contents}"
    filename = "${path.root}/inventory.ini"
}


data "template_file" "storage_classes" {
  template = "${file("${path.module}/templates/storageclasses.tpl")}"
}

resource "local_file" "storage_classes" {
    content = data.template_file.storage_classes.rendered
    filename = "${path.root}/storageclasses.yaml"
}


resource "null_resource" "apply_backends" {
    provisioner "local-exec" {
        command = <<EOF
# Run playbook stuff
ansible-playbook \
    ${path.module}/playbooks/trident/trident-01-pre.yml \
    -b \
    -v \
    -i ${path.root}/inventory.ini \
    -e ansible_user=${var.ansible_user} \
    -e ansible_password=${var.ansible_password} \
    -e ansible_sudo_password=${var.ansible_password}

ansible-playbook \
    ${path.module}/playbooks/trident/trident-install.yml \
    -b \
    -v \
    -i ${path.root}/inventory.ini \
    -e ansible_user=${var.ansible_user} \
    -e ansible_password=${var.ansible_password} \
    -e ansible_sudo_password=${var.ansible_password} \
    -e backend="{{ lookup('file', '${path.cwd}/trident_backends.json') }}" \
    -e storageclasses="{{ lookup('template', '${path.cwd}/storageclasses.yaml', convert_data=no) }}"

EOF
        interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
      //always = "${timestamp()}"
      onTemplateChanged = "${data.template_file.trident_config.rendered}"
      dependency = "${var.dependency}"
  }
}

### S3 

provider "aws" {
  region = "${var.s3_region}"
}

data "terraform_remote_state" "self" {
    backend = "s3"
    config = {
        region = "${var.s3_region}"
        bucket = "${var.s3_bucket}"
        key = "${var.s3_key}"
    }
}

# Upload storage class definitions to S3
resource "aws_s3_bucket_object" "storage_classes" {
  bucket = "${var.s3_bucket}"
  key    = replace(var.s3_key, "terraform.tfstate", "trident/storageclasses.yaml")
  source = "${path.root}/storageclasses.yaml"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  #etag = "${filemd5("${path.root}/inventory/artifacts/admin.conf")}"

  depends_on = [
    null_resource.apply_backends,
    local_file.storage_classes
  ]
}