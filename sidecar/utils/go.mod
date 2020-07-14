module github.com/sgryczan/titania/api/utils

go 1.13

replace github.com/sgryczan/titania/api/models => ../models

require (
	github.com/sgryczan/titania/api/models v0.0.0-00010101000000-000000000000
	github.com/google/go-cmp v0.4.1
	k8s.io/apimachinery v0.18.3
)
