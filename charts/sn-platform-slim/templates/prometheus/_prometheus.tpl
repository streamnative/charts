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

{{/*Define federation datadog annotation*/}}
{{- define "pulsar.prometheus.datadog.annotation" -}}
{{- if .Values.datadog.components.prometheus.enabled }}
{{- if eq .Values.datadog.adVersion "v1" }}
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.prometheus.component }}.check_names: |
  ["openmetrics"]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.prometheus.component }}.init_configs: |
  [{}]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.prometheus.component }}.instances: |
  [
    {
      "prometheus_url": "http://%%host%%:{{ .Values.prometheus.port }}/federate?match[]=%7B__name__%3D~%22pulsar_.%2B%7Cjvm_.%2B%7Ctopic_.%2B%22%7D",
      {{ if .Values.datadog.namespace -}}
      "namespace": "{{ .Values.datadog.namespace }}",
      {{ else -}}
      "namespace": "{{ template "pulsar.namespace" . }}",
      {{ end -}}
      "enable_health_service_check": true,
      "timeout": 1000,
      "metrics": {{ .Values.datadog.components.prometheus.metrics }}
    }
  ]
{{- end }}
{{- if eq .Values.datadog.adVersion "v2" }}
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.prometheus.component }}.checks: |
  {
    "openmetrics": {
      "instances": [
    {
      "openmetrics_endpoint": "http://%%host%%:{{ .Values.prometheus.port }}/federate?match[]=%7B__name__%3D~%22pulsar_.%2B%7Cjvm_.%2B%7Ctopic_.%2B%22%7D",
      {{ if .Values.datadog.namespace -}}
      "namespace": "{{ .Values.datadog.namespace }}",
      {{ else -}}
      "namespace": "{{ template "pulsar.namespace" . }}",
      {{ end -}}
      "enable_health_service_check": true,
      "timeout": 1000,
      "metrics": {{ .Values.datadog.components.prometheus.metrics }}
    }
  ]
    }
  }
{{- end }}
{{- end }}
{{- end }}


{{- define "pulsar.prometheus.data.pvc.name" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.prometheus.component }}-{{ .Values.prometheus.volumes.data.name }}
{{- end }}

{{- define "pulsar.prometheus.data.storage.class" -}}
{{- if  .Values.prometheus.volumes.data.storageClass }}
storageClassName: "{{ template "pulsar.prometheus.data.pvc.name" . }}"
{{- else if .Values.prometheus.volumes.data.storageClassName }}
storageClassName: "{{ .Values.prometheus.volumes.data.storageClassName }}"
{{- end }}
{{- end }}
