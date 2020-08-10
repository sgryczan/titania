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


data "template_file" "storage_classes" {
  template = "${file("${path.module}/templates/storageclasses.tpl")}"
}

resource "local_file" "storage_classes" {
    content = data.template_file.storage_classes.rendered
    filename = "${path.root}/storageclasses.yaml"
}


data "external" "script" {
  program = ["bash", "${path.module}/hack/script.sh"]

  query = {
    namespace = var.namespace
    backend = join("", [path.cwd, "/trident_backends.json"])
    storageclasses = join("", [path.cwd, "/storageclasses.yaml"])
  }
}

