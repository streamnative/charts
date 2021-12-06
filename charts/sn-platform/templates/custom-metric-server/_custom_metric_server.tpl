{{- define "metricserver.prometheus.url" -}}
{{- if and .Values.custom_metric_server.prometheus_url -}}
{{ .Values.custom_metric_server.prometheus_url }}
{{- else -}}
http://{{ template "pulsar.fullname" . }}-{{ .Values.custom_metric_server.component }}-prometheus-service.{{ .Values.namespace }}.svc.cluster.local:9090/
{{- end -}}
{{- end -}}
