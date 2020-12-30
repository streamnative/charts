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

{{- define "presto.worker.service" -}}
{{ template "pulsar.fullname" . }}-presto-worker
{{- end -}}

{{/*
presto service domain
*/}}
{{- define "presto.service_domain" -}}
{{- if .Values.domain.enabled -}}
{{- printf "presto.%s.%s" .Release.Name .Values.domain.suffix -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}

{{/*
pulsar ingress target port for http endpoint
*/}}
{{- define "presto.ingress.targetPort.http" -}}
{{- if .Values.tls.presto.enabled }}
{{- print "https" -}}
{{- else -}}
{{- print "http" -}}
{{- end -}}
{{- end -}}