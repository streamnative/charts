{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}

{{- define "presto.coordinator" -}}
{{ template "pulsar.fullname" . }}-presto-coordinator
{{- end -}}

{{- define "presto.worker" -}}
{{ template "pulsar.fullname" . }}-presto-worker
{{- end -}}

