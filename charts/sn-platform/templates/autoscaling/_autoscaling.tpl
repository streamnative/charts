{{- define "autoscaling.metricserver.prometheus.url" -}}
{{- if and .Values.autoscaling.custom_metric_server.prometheus_url -}}
{{ .Values.autoscaling.custom_metric_server.prometheus_url }}
{{- else -}}
http://{{ template "pulsar.fullname" . }}-{{ .Values.autoscaling.component }}-prometheus-service.{{ .Values.namespace }}.svc.cluster.local:9090/
{{- end -}}
{{- end -}}
