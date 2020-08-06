module github.com/sgryczan/titania/api/handlers

go 1.13

replace github.com/sgryczan/titania/api/models => ../models

replace github.com/sgryczan/titania/api/utils => ../utils

require (
	github.com/gorilla/mux v1.7.4
	github.com/sgryczan/titania/api/models v0.0.0-00010101000000-000000000000
	github.com/sgryczan/titania/api/utils v0.0.0-00010101000000-000000000000
)
