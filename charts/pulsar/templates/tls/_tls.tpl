{{/*
Define the tls issuer
*/}}
{{- define "pulsar.tls.public_issuer" -}}
{{- if and .Values.certs.public_issuer.enabled .Values.certs.public_issuer.issuer_override -}}
{{ .Values.certs.public_issuer.issuer_override }}
{{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.certs.public_issuer.component }}
{{- end -}}
{{- end -}}
