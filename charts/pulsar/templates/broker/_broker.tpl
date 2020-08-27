{{/*
Define the pulsar brroker service
*/}}
{{- define "pulsar.broker.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}
{{- end }}

{{/*
Define the service url
*/}}
{{- define "pulsar.broker.service.url" -}}
{{- if and .Values.tls.enabled .Values.tls.broker.enabled -}}
pulsar+ssl://{{ template "pulsar.broker.service" . }}.{{ template "pulsar.namespace" . }}.svc.cluster.local:{{ .Values.broker.ports.pulsarssl }}
{{- else -}}
pulsar://{{ template "pulsar.broker.service" . }}.{{ template "pulsar.namespace" . }}.svc.cluster.local:{{ .Values.broker.ports.pulsar }}
{{- end -}}
{{- end -}}

{{/*
Define the web service url
*/}}
{{- define "pulsar.web.service.url" -}}
{{- if and .Values.tls.enabled .Values.tls.broker.enabled -}}
https://{{ template "pulsar.broker.service" . }}.{{ template "pulsar.namespace" . }}.svc.cluster.local:{{ .Values.broker.ports.https }}
{{- else -}}
http://{{ template "pulsar.broker.service" . }}.{{ template "pulsar.namespace" . }}.svc.cluster.local:{{ .Values.broker.ports.http }}
{{- end -}}
{{- end -}}

{{/*
Define the hostname
*/}}
{{- define "pulsar.broker.hostname" -}}
${HOSTNAME}.{{ template "pulsar.broker.service" . }}.{{ template "pulsar.namespace" . }}.svc.cluster.local
{{- end -}}

{{/*
Define the broker znode
*/}}
{{- define "pulsar.broker.znode" -}}
{{ .Values.metadataPrefix }}/loadbalance/brokers/{{ template "pulsar.broker.hostname" . }}:{{ .Values.broker.ports.http }}
{{- end }}

{{/*
Define broker zookeeper client tls settings
*/}}
{{- define "pulsar.broker.zookeeper.tls.settings" -}}
{{- if and .Values.tls.enabled (or .Values.tls.zookeeper.enabled (and .Values.tls.broker.enabled .Values.components.kop)) }}
/pulsar/keytool/keytool.sh broker {{ template "pulsar.broker.hostname" . }} true;
{{- end }}
{{- end }}

{{/*
Define broker kop settings
*/}}
{{- define "pulsar.broker.kop.settings" -}}
{{- if .Values.components.kop }}
{{- if and .Values.tls.enabled .Values.tls.broker.enabled }}
export PULSAR_PREFIX_listeners="SSL://{{ template "pulsar.broker.hostname" . }}:{{ .Values.kop.ports.ssl }}";
{{- else }}
export PULSAR_PREFIX_listeners="PLAINTEXT://{{ template "pulsar.broker.hostname" . }}:{{ .Values.kop.ports.plaintext }}";
{{- end }}
{{- end }}
{{- end }}

{{/*
Define broker tls certs mounts
*/}}
{{- define "pulsar.broker.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled (or .Values.tls.broker.enabled (or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled)) }}
- name: broker-certs
  mountPath: "/pulsar/certs/broker"
  readOnly: true
- name: ca
  mountPath: "/pulsar/certs/ca"
  readOnly: true
{{- if or .Values.tls.zookeeper.enabled .Values.components.kop }}
- name: keytool
  mountPath: "/pulsar/keytool/keytool.sh"
  subPath: keytool.sh
{{- end }}
{{- end }}
{{- end }}

{{/*
Define broker tls certs volumes
*/}}
{{- define "pulsar.broker.certs.volumes" -}}
{{- if and .Values.tls.enabled (or .Values.tls.broker.enabled (or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled)) }}
- name: broker-certs
  secret:
    secretName: "{{ .Release.Name }}-{{ .Values.tls.broker.cert_name }}"
    items:
    - key: tls.crt
      path: tls.crt
    - key: tls.key
      path: tls.key
- name: ca
  secret:
    secretName: "{{ .Release.Name }}-ca-tls"
    items:
    - key: ca.crt
      path: ca.crt
{{- if or .Values.tls.zookeeper.enabled .Values.components.kop }}
- name: keytool
  configMap:
    name: "{{ template "pulsar.fullname" . }}-keytool-configmap"
    defaultMode: 0755
{{- end }}
{{- end }}
{{- end }}

{{/*
Define broker token mounts
*/}}
{{- define "pulsar.broker.token.volumeMounts" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
{{- if not .Values.auth.vault.enabled }}
- mountPath: "/pulsar/keys"
  name: token-keys
  readOnly: true
{{- end }}
- mountPath: "/pulsar/tokens"
  name: broker-token
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define broker token volumes
*/}}
{{- define "pulsar.broker.token.volumes" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
{{- if not .Values.auth.vault.enabled }}
- name: token-keys
  secret:
    {{- if not .Values.auth.authentication.jwt.usingSecretKey }}
    secretName: "{{ .Release.Name }}-token-asymmetric-key"
    {{- end}}
    {{- if .Values.auth.authentication.jwt.usingSecretKey }}
    secretName: "{{ .Release.Name }}-token-symmetric-key"
    {{- end}}
    items:
      {{- if .Values.auth.authentication.jwt.usingSecretKey }}
      - key: SECRETKEY
        path: token/secret.key
      {{- else }}
      - key: PUBLICKEY
        path: token/public.key
      - key: PRIVATEKEY
        path: token/private.key
      {{- end}}
{{- end }}
- name: broker-token
  secret:
    secretName: "{{ .Release.Name }}-token-{{ .Values.auth.superUsers.broker }}"
    items:
      - key: TOKEN
        path: broker/token
{{- end }}
{{- end }}
{{- end }}


{{/*
Define broker log mounts
*/}}
{{- define "pulsar.broker.log.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}-log4j2"
  mountPath: "{{ template "pulsar.home" .}}/conf/log4j2.yaml"
  subPath: log4j2.yaml
{{- end }}

{{/*
Define broker log volumes
*/}}
{{- define "pulsar.broker.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}-log4j2"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}"
{{- end }}

{{/*
Define function worker config volume mount
*/}}
{{- define "pulsar.function.worker.config.volumeMounts" -}}
{{- if .Values.components.functions }}
- name: "function-worker-config"
  mountPath: "{{ template "pulsar.home" . }}/conf/functions_worker.yml"
  subPath: functions_worker.yml
{{- end }}
{{- end }}

{{/*
Define function worker config volume
*/}}
{{- define "pulsar.function.worker.config.volumes" -}}
{{- if .Values.components.functions }}
- name: "function-worker-config"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.functions.component }}-configfile"
{{- end }}
{{- end }}

{{/*Define broker datadog annotation*/}}
{{- define "pulsar.broker.datadog.annotation" -}}
{{- if .Values.datadog.components.broker.enabled }}
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}.check_names: |
  ["openmetrics"]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}.init_configs: |
  [{}]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}.instances: |
  [
    {
      "prometheus_url": "http://%%host%%:{{ .Values.broker.ports.http }}/metrics",
      "namespace": "{{ .Values.datadog.namespace }}",
      "metrics": {{ .Values.datadog.components.broker.metrics }},
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
      },
      "tags": [
        "pulsar-broker: {{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}"
      ]
    }
  ]
{{- end }}
{{- end }}

{{/*
Define custom runtime options mounts
*/}}
{{- define "pulsar.broker.runtime.volumeMounts" -}}
{{- if .Values.functions.enableCustomizerRuntime }}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}-runtime"
  mountPath: "{{ template "pulsar.home" .}}/{{ .Values.functions.pulsarExtraClasspath }}"
{{- end }}
{{- end }}

{{/*
Define broker runtime volumes
*/}}
{{- define "pulsar.broker.runtime.volumes" -}}
{{- if .Values.functions.enableCustomizerRuntime }}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}-runtime"
  hostPath:
    path: /proc
{{- end }}
{{- end }}

{{/*
Define gcs offload options mounts
*/}}
{{- define "pulsar.broker.offload.volumeMounts" -}}
{{- if .Values.broker.offload.gcs.enabled }}
- name: gcs-offloader-service-acccount
  mountPath: /pulsar/srvaccts
  readOnly: true
{{- end }}
{{- end }}

{{/*
Define gcs offload options mounts
*/}}
{{- define "pulsar.broker.offload.volumes" -}}
{{- if .Values.broker.offload.gcs.enabled }}
- name: gcs-offloader-service-acccount
  secret:
    secretName: "{{ .Release.Name }}-gcs-offloader-service-account"
    items:
      - key: gcs.json
        path: gcs.json
{{- end }}
{{- end }}

