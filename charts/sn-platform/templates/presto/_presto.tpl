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

{{/*
pulsar presto worker image
*/}}
{{- define "presto.worker.image" -}}
{{- if .Values.images.presto_worker }}
image: "{{ .Values.images.presto_worker.repository }}:{{ .Values.images.presto_worker.tag }}"
imagePullPolicy: {{ .Values.images.presto_worker.pullPolicy }}
{{- else }}
image: "{{ .Values.images.presto.repository }}:{{ .Values.images.presto.tag }}"
imagePullPolicy: {{ .Values.images.presto.pullPolicy }}
{{- end }}
{{- end }}