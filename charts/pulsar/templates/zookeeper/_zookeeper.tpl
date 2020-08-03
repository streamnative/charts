{{/*
Define the pulsar zookeeper
*/}}
{{- define "pulsar.zookeeper.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}
{{- end }}

{{/*
Define the pulsar zookeeper
*/}}
{{- define "pulsar.zookeeper.connect" -}}
{{$zk:=.Values.pulsar_metadata.userProvidedZookeepers}}
{{- if and (not .Values.components.zookeeper) $zk }}
{{- $zk -}}
{{ else }}
{{- if not (and .Values.tls.enabled .Values.tls.zookeeper.enabled) -}}
{{ template "pulsar.zookeeper.service" . }}:{{ .Values.zookeeper.ports.client }}
{{- end -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled -}}
{{ template "pulsar.zookeeper.service" . }}:{{ .Values.zookeeper.ports.clientTls }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Define the zookeeper hostname
*/}}
{{- define "pulsar.zookeeper.hostname" -}}
${HOSTNAME}.{{ template "pulsar.zookeeper.service" . }}.{{ template "pulsar.namespace" . }}.svc.cluster.local
{{- end -}}

{{/*
Define zookeeper tls settings
*/}}
{{- define "pulsar.zookeeper.tls.settings" -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
/pulsar/keytool/keytool.sh zookeeper {{ template "pulsar.zookeeper.hostname" . }} false;
{{- end }}
{{- end }}

{{/*
Define zookeeper certs mounts
*/}}
{{- define "pulsar.zookeeper.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
- mountPath: "/pulsar/certs/zookeeper"
  name: zookeeper-certs
  readOnly: true
- mountPath: "/pulsar/certs/ca"
  name: ca
  readOnly: true
- name: keytool
  mountPath: "/pulsar/keytool/keytool.sh"
  subPath: keytool.sh
{{- end }}
{{- end }}

{{/*
Define zookeeper certs volumes
*/}}
{{- define "pulsar.zookeeper.certs.volumes" -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
- name: zookeeper-certs
  secret:
    secretName: "{{ .Release.Name }}-{{ .Values.tls.zookeeper.cert_name }}"
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
- name: keytool
  configMap:
    name: "{{ template "pulsar.fullname" . }}-keytool-configmap"
    defaultMode: 0755
{{- end}}
{{- end }}


{{/*
Define zookeeper log mounts
*/}}
{{- define "pulsar.zookeeper.log.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-log4j2"
  mountPath: "{{ template "pulsar.home" . }}/conf/log4j2.yaml"
  subPath: log4j2.yaml
{{- end }}

{{/*
Define zookeeper log volumes
*/}}
{{- define "pulsar.zookeeper.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-log4j2"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}"
{{- end }}

{{/*Define zookeeper datadog annotation*/}}
{{- define "pulsar.zookeeper.datadog.annotation"}}
{{- if .Values.datadog.components.zookeeper.enabled }}
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}.check_names: |
  ["openmetrics"]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}.init_configs: |
  [{}]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}.instances: |
  [
    {
      "prometheus_url": "http://%%host%%:{{ .Values.zookeeper.ports.metrics }}/metrics",
      "namespace": "{{ .Values.datadog.namespace }}",
      "metrics": {{ .Values.datadog.components.zookeeper.metrics }},
      "health_service_check": true,
      "prometheus_timeout": 1000,
      "max_returned_metrics": 1000000,
      "type_overrides": {
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
        "pulsar-zookeeper: {{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}"
      ]
    }
  ]
{{- end }}
{{- end }}

{{/*
Define zookeeper data mounts
*/}}
{{- define "pulsar.zookeeper.data.volumeMounts" -}}
{{- if .Values.zookeeper.volumes.useSeparateDiskForTxlog }}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.data.name }}"
  mountPath: "/pulsar/data/zookeeper"
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.dataLog.name }}"
  mountPath: "/pulsar/data/zookeeper-datalog"
{{- else }}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.data.name }}"
  mountPath: "/pulsar/data"
{{- end }}
{{- end }}

{{/*
Define zookeeper data volumes
*/}}
{{- define "pulsar.zookeeper.data.volumes" -}}
{{- if not (and .Values.volumes.persistence .Values.zookeeper.volumes.persistence) }}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.data.name }}"
  emptyDir: {}
{{- if .Values.zookeeper.volumes.useSeparateDiskForTxlog }}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.dataLog.name }}"
  emptyDir: {}
{{- end }}
{{- end }}
{{- end }}

{{/*
Define zookeeper data volumes
*/}}
{{- define "pulsar.zookeeper.data.volumeClaimTemplates" -}}
{{- if and .Values.volumes.persistence .Values.zookeeper.volumes.persistence }}
- metadata:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.data.name }}"
  spec:
    accessModes: [ "ReadWriteOnce" ]
    resources:
      requests:
        storage: {{ .Values.zookeeper.volumes.data.size }}
  {{- if and .Values.volumes.local_storage .Values.zookeeper.volumes.data.local_storage }}
    storageClassName: "local-storage"
  {{- else }}
    {{- if  .Values.zookeeper.volumes.data.storageClass }}
    storageClassName: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.data.name }}"
    {{- else if .Values.zookeeper.volumes.data.storageClassName }}
    storageClassName: {{ .Values.zookeeper.volumes.data.storageClassName }}
    {{- end -}}
  {{- end }}
{{- if .Values.zookeeper.volumes.useSeparateDiskForTxlog }}
- metadata:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.dataLog.name }}"
  spec:
    accessModes: [ "ReadWriteOnce" ]
    resources:
      requests:
        storage: {{ .Values.zookeeper.volumes.dataLog.size }}
  {{- if and .Values.volumes.local_storage .Values.zookeeper.volumes.data.local_storage }}
    storageClassName: "local-storage"
  {{- else }}
    {{- if  .Values.zookeeper.volumes.dataLog.storageClass }}
    storageClassName: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.dataLog.name }}"
    {{- else if .Values.zookeeper.volumes.dataLog.storageClassName }}
    storageClassName: {{ .Values.zookeeper.volumes.dataLog.storageClassName }}
    {{- end -}}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Define zookeeper gen-zk-conf volume mounts
*/}}
{{- define "pulsar.zookeeper.genzkconf.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-genzkconf"
  mountPath: "{{ template "pulsar.home" . }}/bin/gen-zk-conf.sh"
  subPath: gen-zk-conf.sh
{{- end }}

{{/*
Define zookeeper gen-zk-conf volumes
*/}}
{{- define "pulsar.zookeeper.genzkconf.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-genzkconf"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-genzkconf-configmap"
    defaultMode: 0755
{{- end }}