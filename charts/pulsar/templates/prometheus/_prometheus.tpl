{{/*
Define toolset token mounts
*/}}
{{- define "pulsar.prometheus.token.volumeMounts" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
- mountPath: "/pulsar/tokens"
  name: client-token
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define toolset token volumes
*/}}
{{- define "pulsar.prometheus.token.volumes" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
- name: client-token
  secret:
    secretName: "{{ .Release.Name }}-token-{{ .Values.auth.superUsers.client }}"
    items:
      - key: TOKEN
        path: client/token
{{- end }}
{{- end }}
{{- end }}

{{/*Define prometheus service account*/}}
{{- define "pulsar.prometheus.serviceAccount" -}}
{{- if .Values.prometheus.serviceAccount.create -}}
    {{- if .Values.prometheus.serviceAccount.name -}}
{{ .Values.prometheus.serviceAccount.name }}
    {{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.rbac.roleName }}
    {{- end -}}
{{- else -}}
{{ .Values.prometheus.serviceAccount.name }}
{{- end -}}
{{- end -}}
