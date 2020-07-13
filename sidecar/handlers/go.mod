module bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/handlers

go 1.13

replace bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/models => ../models

replace bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/utils => ../utils

require (
	bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/models v0.0.0-00010101000000-000000000000
	bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/utils v0.0.0-00010101000000-000000000000
	github.com/gorilla/mux v1.7.4
)
