{{- define "pnnlmiscscripts.pixiecore.server" -}}
{{- if and (hasKey . "section") (hasKey .section "server") .section.server -}}
{{ .section.server }}
{{- else -}}
docker.io
{{- end -}}
{{- end -}}

{{- define "pnnlmiscscripts.pixiecore.prefix" -}}
{{- if and (hasKey . "section") (hasKey .section "prefix") .section.prefix -}}
/{{ .section.prefix }}
{{- end -}}
{{- end -}}

{{- define "pnnlmiscscripts.pixiecore.org" -}}
{{- if and (hasKey . "section") (hasKey .section "org") .section.org -}}
{{ .section.org }}
{{- else -}}
pnnlmiscscripts
{{- end -}}
{{- end -}}

{{- define "pnnlmiscscripts.pixiecore.repo" -}}
{{- if and (hasKey . "section") (hasKey .section "repo") .section.repo -}}
{{ .section.repo }}
{{- else -}}
pixiecore
{{- end -}}
{{- end -}}

{{- define "pnnlmiscscripts.pixiecore.tag" -}}
{{- if and (hasKey . "section") (hasKey .section "tag") .section.tag -}}
{{ .section.tag }}
{{- else -}}
1.0.1-2
{{- end -}}
{{- end -}}

{{- /*
How to use:
  {{ dict "dot" . "section" (index .Values "pixiecore") | include "pnnlmiscscripts.pixiecore.image" }}
*/ -}}
{{- define "pnnlmiscscripts.pixiecore.image" -}}
{{- include "pnnlmiscscripts.pixiecore.server" . -}}{{- include "pnnlmiscscripts.pixiecore.prefix" . -}}/{{- include "pnnlmiscscripts.pixiecore.org" . -}}/{{- include "pnnlmiscscripts.pixiecore.repo" . -}}:{{- include "pnnlmiscscripts.pixiecore.tag" . -}}
{{- end -}}
