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
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.prometheus.component }}.check_names: |
  ["openmetrics"]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.prometheus.component }}.init_configs: |
  [{}]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.prometheus.component }}.instances: |
  [
    {
      "prometheus_url": "http://%%host%%:{{ .Values.prometheus.port }}/federate?match[]=%7B__name__%3D~%22pulsar_.%2B%7Cjvm_.%2B%7Ctopic_.%2B%22%7D",
      "namespace": "{{ .Values.datadog.namespace }}",
      "metrics": {{ .Values.datadog.components.prometheus.metrics }},
      "health_service_check": true,
      "prometheus_timeout": 1000,
      "max_returned_metrics": 1000000,
      "type_overrides": {
        "pulsar_topics_count": "gauge",
        "pulsar_rate_in": "gauge",
        "pulsar_rate_out": "gauge",
        "pulsar_subscriptions_count": "gauge",
        "pulsar_producers_count": "gauge",
        "pulsar_consumers_count": "gauge",
        "pulsar_throughput_in": "gauge",
        "pulsar_throughput_out": "gauge",
        "pulsar_storage_size": "gauge",
        "pulsar_msg_backlog": "gauge",
        "pulsar_storage_backlog_size": "gauge",
        "pulsar_storage_offloaded_size": "gauge",
        "pulsar_storage_write_latency_le_0_5": "gauge",
        "pulsar_storage_write_latency_le_1": "gauge",
        "pulsar_storage_write_latency_le_5": "gauge",
        "pulsar_storage_write_latency_le_10": "gauge",
        "pulsar_storage_write_latency_le_20": "gauge",
        "pulsar_storage_write_latency_le_50": "gauge",
        "pulsar_storage_write_latency_le_100": "gauge",
        "pulsar_storage_write_latency_le_200": "gauge",
        "pulsar_storage_write_latency_le_1000": "gauge",
        "pulsar_storage_write_latency_overflow": "gauge",
        "pulsar_entry_size_le_128": "gauge",
        "pulsar_entry_size_le_512": "gauge",
        "pulsar_entry_size_le_1_kb": "gauge",
        "pulsar_entry_size_le_2_kb": "gauge",
        "pulsar_entry_size_le_4_kb": "gauge",
        "pulsar_entry_size_le_16_kb": "gauge",
        "pulsar_entry_size_le_100_kb": "gauge",
        "pulsar_entry_size_le_1_mb": "gauge",
        "pulsar_entry_size_le_overflow": "gauge",
        "pulsar_subscription_back_log": "gauge",
        "pulsar_subscription_back_log_no_delayed": "gauge",
        "pulsar_subscription_delayed": "gauge",
        "pulsar_subscription_msg_rate_redeliver": "gauge",
        "pulsar_subscription_unacked_messages": "gauge",
        "pulsar_subscription_blocked_on_unacked_messages": "gauge",
        "pulsar_subscription_msg_rate_out": "gauge",
        "pulsar_subscription_msg_throughput_out": "gauge",
        "pulsar_in_bytes_total": "counter",
        "pulsar_in_messages_total": "counter",
        "topic_load_times": "counter",
        "jvm_memory_bytes_used": "gauge",
        "jvm_memory_bytes_committed": "gauge",
        "jvm_memory_bytes_max": "gauge",
        "jvm_memory_bytes_init": "gauge",
        "jvm_memory_pool_bytes_used": "gauge",
        "jvm_memory_pool_bytes_committed": "gauge",
        "jvm_memory_pool_bytes_max": "gauge",
        "jvm_memory_pool_bytes_init": "gauge",
        "jvm_classes_loaded": "gauge",
        "jvm_classes_loaded_total": "counter",
        "jvm_classes_unloaded_total": "counter",
        "jvm_buffer_pool_used_bytes": "gauge",
        "jvm_buffer_pool_capacity_bytes": "gauge",
        "jvm_buffer_pool_used_buffers": "gauge",
        "jvm_threads_current": "gauge",
        "jvm_threads_daemon": "gauge",
        "jvm_threads_peak": "gauge",
        "jvm_threads_started_total": "counter",
        "jvm_threads_deadlocked": "gauge",
        "jvm_threads_deadlocked_monitor": "gauge",
        "jvm_gc_collection_seconds_count": "gauge",
        "jvm_gc_collection_seconds_sum": "gauge",
        "jvm_memory_direct_bytes_max": "gauge"
      }
    }
  ]
{{- end }}
{{- end }}
