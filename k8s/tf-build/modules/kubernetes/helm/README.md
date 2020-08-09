# How to user

main.tf:
```
provider "helm" {
    kubernetes {
        config_path = "<path to kubeconfig>"
    }
}

module "helm" {
    source = "git::https://github.com/sgryczan/titania.git//k8s/tf-build/modules/kubernetes/helm

    release_name = "nginx-ingress"
    chart = "nginx-ingress"
    namespace = "ingress"
    create_namespace = true
}
```