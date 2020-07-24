{{/*
The namespace to run functions
*/}}
{{- define "pulsar.functions.namespace" -}}
{{- if .Values.functions.jobNamespace }}
{{- .Values.functions.jobNamespace }}
{{- else }}
{{- template "pulsar.namespace" . }}
{{- end }}
{{- end }}
