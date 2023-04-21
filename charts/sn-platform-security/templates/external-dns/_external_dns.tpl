{{/*Define external_dns service account*/}}
{{- define "external_dns.serviceAccount" -}}
{{- if .Values.external_dns.serviceAcct.name -}}
{{ .Values.external_dns.serviceAcct.name }}
{{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.external_dns.component }}
{{- end -}}
{{- end -}}
