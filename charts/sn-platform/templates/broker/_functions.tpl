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

{{/*
The pulsar root directory of functions image
*/}}
{{- define "pulsar.functions.pulsarRootDir" -}}
{{- if .Values.functions.pulsarRootDir }}
{{- .Values.functions.pulsarRootDir }}
{{- else }}
{{- template "pulsar.home" . }}
{{- end }}
{{- end }}