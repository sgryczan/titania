output "kubeconfig" {
  value = rke_cluster.cluster.kube_config_yaml
}

output "rkeconfig" {
  value = rke_cluster.cluster.rke_cluster_yaml
}
