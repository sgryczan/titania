---
# disable upgrade cluster
upgrade_cluster_setup: false

# Enable kubeadm experimental control plane
kubeadm_control_plane: false

# Experimental kubeadm etcd deployment mode. Available only for new deployment
etcd_kubeadm_enabled: false

# An experimental dev/test only dynamic volumes provisioner,
# for PetSets. Works for kube>=v1.3 only.
kube_hostpath_dynamic_provisioner: "false"

# change to 0.0.0.0 to enable insecure access from anywhere (not recommended)
kube_apiserver_insecure_bind_address: 127.0.0.1

# By default the external API listens on all interfaces, this can be changed to
# listen on a specific address/interface.
kube_apiserver_bind_address: 0.0.0.0

# A port range to reserve for services with NodePort visibility.
# Inclusive at both ends of the range.
kube_apiserver_node_port_range: "30000-32767"

# ETCD backend for k8s data
kube_apiserver_storage_backend: etcd3

# By default, force back to etcd2. Set to true to force etcd3 (experimental!)
force_etcd3: false

kube_etcd_cacert_file: ca.pem
kube_etcd_cert_file: node-{{ inventory_hostname }}.pem
kube_etcd_key_file: node-{{ inventory_hostname }}-key.pem

# Associated interfaces must be reachable by the rest of the cluster, and by
# CLI/web clients.
kube_controller_manager_bind_address: 0.0.0.0
kube_scheduler_bind_address: 0.0.0.0

# discovery_timeout modifies the discovery timeout
discovery_timeout: 5m0s

# Instruct first master to refresh kubeadm token
kubeadm_refresh_token: true

# audit support
kubernetes_audit: false
# path to audit log file
audit_log_path: /var/log/audit/kube-apiserver-audit.log
# num days
audit_log_maxage: 30
# the num of audit logs to retain
audit_log_maxbackups: 1
# the max size in MB to retain
audit_log_maxsize: 100
# policy file
audit_policy_file: "{{ kube_config_dir }}/audit-policy/apiserver-audit-policy.yaml"
# custom audit policy rules (to replace the default ones)
# audit_policy_custom_rules: |
#   - level: None
#     users: []
#     verbs: []
#     resources: []

# audit log hostpath
audit_log_name: audit-logs
audit_log_hostpath: /var/log/kubernetes/audit
audit_log_mountpath: "{{ audit_log_path | dirname }}"

# audit policy hostpath
audit_policy_name: audit-policy
audit_policy_hostpath: "{{ audit_policy_file | dirname }}"
audit_policy_mountpath: "{{ audit_policy_hostpath }}"

# Limits for kube components
kube_controller_memory_limit: 512M
kube_controller_cpu_limit: 250m
kube_controller_memory_requests: 100M
kube_controller_cpu_requests: 100m
kube_controller_node_monitor_grace_period: 40s
kube_controller_node_monitor_period: 5s
kube_controller_pod_eviction_timeout: 5m0s
kube_controller_terminated_pod_gc_threshold: 12500
kube_scheduler_memory_limit: 512M
kube_scheduler_cpu_limit: 250m
kube_scheduler_memory_requests: 170M
kube_scheduler_cpu_requests: 80m
kube_apiserver_memory_limit: 2000M
kube_apiserver_cpu_limit: 800m
kube_apiserver_memory_requests: 256M
kube_apiserver_cpu_requests: 100m
kube_apiserver_request_timeout: "1m0s"

# 1.9 and below Admission control plug-ins
kube_apiserver_admission_control:
  - NamespaceLifecycle
  - LimitRanger
  - ServiceAccount
  - DefaultStorageClass
  - PersistentVolumeClaimResize
  - MutatingAdmissionWebhook
  - ValidatingAdmissionWebhook
  - ResourceQuota

# 1.10+ admission plugins
kube_apiserver_enable_admission_plugins: []

# 1.10+ list of disabled admission plugins
kube_apiserver_disable_admission_plugins: []

# extra runtime config
kube_api_runtime_config: []

## Enable/Disable Kube API Server Authentication Methods
kube_basic_auth: false
kube_token_auth: false
kube_oidc_auth: false
kube_webhook_token_auth: false

## Variables for OpenID Connect Configuration https://kubernetes.io/docs/admin/authentication/
## To use OpenID you have to deploy additional an OpenID Provider (e.g Dex, Keycloak, ...)

# kube_oidc_url: https:// ...
# kube_oidc_client_id: kubernetes
## Optional settings for OIDC
# kube_oidc_username_claim: sub
# kube_oidc_username_prefix: oidc:
# kube_oidc_groups_claim: groups
# kube_oidc_groups_prefix: oidc:
# Copy oidc CA file to the following path if needed
# kube_oidc_ca_file: {{ kube_cert_dir }}/ca.pem
# Optionally include a base64-encoded oidc CA cert
# kube_oidc_ca_cert: c3RhY2thYnVzZS5jb20...

## Variables for webhook token auth https://kubernetes.io/docs/reference/access-authn-authz/authentication/#webhook-token-authentication
# kube_webhook_token_auth_url: https://...

# List of the preferred NodeAddressTypes to use for kubelet connections.
kubelet_preferred_address_types: 'InternalDNS,InternalIP,Hostname,ExternalDNS,ExternalIP'

## Extra args for k8s components passing by kubeadm
kube_kubeadm_apiserver_extra_args: {}
kube_kubeadm_controller_extra_args: {}
kube_kubeadm_scheduler_extra_args: {}

## Extra control plane host volume mounts
## Example:
# apiserver_extra_volumes:
#  - name: name
#    hostPath: /host/path
#    mountPath: /mount/path
#    readOnly: true
apiserver_extra_volumes: {}
controller_manager_extra_volumes: {}
scheduler_extra_volumes: {}

## Encrypting Secret Data at Rest
kube_encrypt_secret_data: false
kube_encrypt_token: "{{ lookup('password', credentials_dir + '/kube_encrypt_token.creds length=32 chars=ascii_letters,digits') }}"
# Must be either: aescbc, secretbox or aesgcm
kube_encryption_algorithm: "aescbc"

# You may want to use ca.pem depending on your situation
kube_front_proxy_ca: "front-proxy-ca.pem"

# If non-empty, will use this string as identification instead of the actual hostname
kube_override_hostname: >-
  {%- if cloud_provider is defined and cloud_provider in [ 'aws' ] -%}
  {%- else -%}
  {{ inventory_hostname }}
  {%- endif -%}

secrets_encryption_query: "resources[*].providers[0].{{kube_encryption_algorithm}}.keys[0].secret"
