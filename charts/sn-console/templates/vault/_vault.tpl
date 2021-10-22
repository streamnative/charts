{{/*Define vault service account*/}}
{{- define "sn_console.vault.serviceAccount" -}}
{{- if .Values.vault.serviceAccount.created -}}
    {{- if .Values.vault.serviceAccount.name -}}
{{ .Values.vault.serviceAccount.name }}
    {{- else -}}
{{ template "sn_console.fullname" . }}-vault-init-acct
    {{- end -}}
{{- else -}}
{{ .Values.vault.serviceAccount.name }}
{{- end -}}
{{- end -}}
