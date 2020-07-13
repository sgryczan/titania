module bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar

go 1.13

require (
	bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/handlers v0.0.0-00010101000000-000000000000
	github.com/go-openapi/errors v0.19.4
	github.com/go-openapi/runtime v0.19.15
	github.com/go-openapi/strfmt v0.19.5
	github.com/go-openapi/swag v0.19.9
	github.com/go-openapi/validate v0.19.8
	github.com/gorilla/mux v1.7.4
	github.com/streadway/amqp v0.0.0-20200108173154-1c71cc93ed71
)

replace bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/handlers => ./handlers

replace bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/utils => ./utils

replace bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/models => ./models
