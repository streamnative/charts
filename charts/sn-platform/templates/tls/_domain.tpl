{{/*
Define the domain suffix
*/}}
{{- define "domain.suffix" -}}
{{- printf ".%s" .Values.domain.suffix -}}
{{- end -}}
