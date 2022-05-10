{{/* Grafana Service name */}}
{{- define "pulsar.grafana.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.grafana.component }}
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