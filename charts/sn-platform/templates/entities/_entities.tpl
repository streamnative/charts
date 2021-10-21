{{/*
Define the entities admin service url
*/}}
{{- define "entities.admin.service.url" -}}
{{- if .Values.entities.adminServiceUrl -}}
{{ .Values.entities.adminServiceUrl }}
{{- else -}}
{{- if and .Values.tls.enabled .Values.tls.broker.enabled -}}
https://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}:{{ .Values.broker.ports.https }}
{{- else -}}
http://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}:{{ .Values.broker.ports.http }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "entities.name-suffix" -}}
{{ sha256sum .name | trunc 8 }}
{{- end -}}