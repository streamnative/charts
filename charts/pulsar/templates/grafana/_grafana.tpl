{{/*
Define toolset token mounts
*/}}
{{- define "pulsar.grafana.token.volumeMounts" -}}
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
{{- define "pulsar.grafana.token.volumes" -}}
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

{{/* Grafana volumes storage class */}}
{{- define "pulsar.grafana.volumes.pvc.name" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.grafana.component }}-{{ .Values.grafana.volumes.data.name }}
{{- end }}

{{- define "pulsar.grafana.volumes.storage.class" -}}
{{- if and .Values.volumes.local_storage .Values.grafana.volumes.data.local_storage }}
storageClassName: "local-storage"
{{- else }}
  {{- if  .Values.grafana.volumes.data.storageClass }}
storageClassName: "{{ template "pulsar.grafana.volumes.pvc.name" . }}"
  {{- else if .Values.grafana.volumes.data.storageClassName }}
storageClassName: "{{ .Values.grafana.volumes.data.storageClassName }}"
  {{- end -}}
{{- end }}
{{- end }}