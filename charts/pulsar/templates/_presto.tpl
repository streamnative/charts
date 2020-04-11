{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "presto.coordinator" -}}
{{ template "pulsar.fullname" . }}-presto-coordinator
{{- end -}}

{{- define "presto.worker" -}}
{{ template "pulsar.fullname" . }}-presto-worker
{{- end -}}

{{- define "presto.service" -}}
{{ template "pulsar.fullname" . }}-presto
{{- end -}}