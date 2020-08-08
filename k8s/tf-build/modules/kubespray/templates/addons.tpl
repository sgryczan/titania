---
# Kubernetes dashboard
# RBAC required. see docs/getting-started.md for access details.
dashboard_enabled: true

# Helm deployment
helm_enabled: false

# Registry deployment
registry_enabled: false
# registry_namespace: kube-system
# registry_storage_class: ""
# registry_disk_size: "10Gi"

# Metrics Server deployment
metrics_server_enabled: ${metrics_server_enabled}
metrics_server_kubelet_insecure_tls: ${metrics_server_kubelet_insecure_tls}
metrics_server_metric_resolution: ${metrics_server_metric_resolution}
metrics_server_kubelet_preferred_address_types: "${metrics_server_kubelet_preferred_address_types}"

# Rancher Local Path Provisioner
local_path_provisioner_enabled: false
# local_path_provisioner_namespace: "local-path-storage"
# local_path_provisioner_storage_class: "local-path"
# local_path_provisioner_reclaim_policy: Delete
# local_path_provisioner_claim_root: /opt/local-path-provisioner/
# local_path_provisioner_debug: false
# local_path_provisioner_image_repo: "rancher/local-path-provisioner"
# local_path_provisioner_image_tag: "v0.0.2"

# Local volume provisioner deployment
local_volume_provisioner_enabled: false
# local_volume_provisioner_namespace: kube-system
# local_volume_provisioner_storage_classes:
#   local-storage:
#     host_dir: /mnt/disks
#     mount_dir: /mnt/disks
#     volume_mode: Filesystem
#     fs_type: ext4
#   fast-disks:
#     host_dir: /mnt/fast-disks
#     mount_dir: /mnt/fast-disks
#     block_cleaner_command:
#       - "/scripts/shred.sh"
#       - "2"
#     volume_mode: Filesystem
#     fs_type: ext4

# CephFS provisioner deployment
cephfs_provisioner_enabled: false
# cephfs_provisioner_namespace: "cephfs-provisioner"
# cephfs_provisioner_cluster: ceph
# cephfs_provisioner_monitors: "172.24.0.1:6789,172.24.0.2:6789,172.24.0.3:6789"
# cephfs_provisioner_admin_id: admin
# cephfs_provisioner_secret: secret
# cephfs_provisioner_storage_class: cephfs
# cephfs_provisioner_reclaim_policy: Delete
# cephfs_provisioner_claim_root: /volumes
# cephfs_provisioner_deterministic_names: true

# RBD provisioner deployment
rbd_provisioner_enabled: false
# rbd_provisioner_namespace: rbd-provisioner
# rbd_provisioner_replicas: 2
# rbd_provisioner_monitors: "172.24.0.1:6789,172.24.0.2:6789,172.24.0.3:6789"
# rbd_provisioner_pool: kube
# rbd_provisioner_admin_id: admin
# rbd_provisioner_secret_name: ceph-secret-admin
# rbd_provisioner_secret: ceph-key-admin
# rbd_provisioner_user_id: kube
# rbd_provisioner_user_secret_name: ceph-secret-user
# rbd_provisioner_user_secret: ceph-key-user
# rbd_provisioner_user_secret_namespace: rbd-provisioner
# rbd_provisioner_fs_type: ext4
# rbd_provisioner_image_format: "2"
# rbd_provisioner_image_features: layering
# rbd_provisioner_storage_class: rbd
# rbd_provisioner_reclaim_policy: Delete

# Nginx ingress controller deployment
ingress_nginx_enabled: false
# ingress_nginx_host_network: false
ingress_publish_status_address: ""
# ingress_nginx_nodeselector:
#   beta.kubernetes.io/os: "linux"
# ingress_nginx_tolerations:
#   - key: "node-role.kubernetes.io/master"
#     operator: "Equal"
#     value: ""
#     effect: "NoSchedule"
# ingress_nginx_namespace: "ingress-nginx"
# ingress_nginx_insecure_port: 80
# ingress_nginx_secure_port: 443
# ingress_nginx_configmap:
#   map-hash-bucket-size: "128"
#   ssl-protocols: "SSLv2"
# ingress_nginx_configmap_tcp_services:
#   9000: "default/example-go:8080"
# ingress_nginx_configmap_udp_services:
#   53: "kube-system/coredns:53"

# Cert manager deployment
cert_manager_enabled: false
# cert_manager_namespace: "cert-manager"
