module bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/utils

go 1.13

replace bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/models => ../models

require (
	bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/models v0.0.0-00010101000000-000000000000
	github.com/google/go-cmp v0.4.1
	k8s.io/apimachinery v0.18.3
)
