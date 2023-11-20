{{/*
Define the pulsar autorecovery service
*/}}
{{- define "pulsar.autorecovery.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.autorecovery.component }}
{{- end }}

{{/*
Define the autorecovery hostname
*/}}
{{- define "pulsar.autorecovery.hostname" -}}
${HOSTNAME}.{{ template "pulsar.autorecovery.service" . }}.{{ template "pulsar.namespace" . }}.svc.cluster.local
{{- end -}}

{{/*Define broker autorecovery name*/}}
{{- define "pulsar.autorecovery.podName" -}}
{{- print "autorecovery" -}}
{{- end -}}

{{/*Define autorecovery datadog annotation*/}}
{{- define  "pulsar.autorecovery.datadog.annotation" -}}
{{- if .Values.datadog.components.autorecovery.enabled }}
ad.datadoghq.com/{{ template "pulsar.autorecovery.podName" . }}.check_names: |
  ["openmetrics"]
ad.datadoghq.com/{{ template "pulsar.autorecovery.podName" . }}.init_configs: |
  [{}]
ad.datadoghq.com/{{ template "pulsar.autorecovery.podName" . }}.instances: |
  [
    {
      "prometheus_url": "http://%%host%%:{{ .Values.autorecovery.ports.http }}/metrics",
      {{ if .Values.datadog.namespace -}}
      "namespace": "{{ .Values.datadog.namespace }}",
      {{ else -}}
      "namespace": "{{ template "pulsar.namespace" . }}",
      {{ end -}}
      "metrics": {{ .Values.datadog.components.autorecovery.metrics }},
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
        "jvm_memory_direct_bytes_used": "gauge",
        "jvm_threads_current": "gauge",
        "jvm_threads_daemon": "gauge",
        "jvm_threads_peak": "gauge",
        "jvm_threads_started_total": "gauge",
        "jvm_threads_deadlocked": "gauge",
        "jvm_threads_deadlocked_monitor": "gauge",
        "jvm_gc_collection_seconds_count": "gauge",
        "jvm_gc_collection_seconds_sum": "gauge",
        "jvm_memory_direct_bytes_max": "gauge"
      },
      "tags": [
        "pulsar-autorecovery: {{ template "pulsar.fullname" . }}-{{ .Values.autorecovery.component }}"
      ]
    }
  ]
{{- end }}
{{- end }}

{{/*
Define autorecovery zookeeper client tls settings
*/}}
{{- define "pulsar.autorecovery.zookeeper.tls.settings" -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
/pulsar/keytool/keytool.sh autorecovery {{ template "pulsar.autorecovery.hostname" . }} true;
{{- end }}
{{- end }}

{{/*
Define autorecovery tls certs mounts
*/}}
{{- define "pulsar.autorecovery.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
- name: autorecovery-certs
  mountPath: "/pulsar/certs/autorecovery"
  readOnly: true
- name: ca
  mountPath: "/pulsar/certs/ca"
  readOnly: true
{{- if .Values.tls.zookeeper.enabled }}
- name: keytool
  mountPath: "/pulsar/keytool/keytool.sh"
  subPath: keytool.sh
{{- end }}
{{- end }}
{{- end }}

{{/*
Define autorecovery tls certs volumes
*/}}
{{- define "pulsar.autorecovery.certs.volumes" -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
- name: autorecovery-certs
  secret:
    secretName: "{{ template "pulsar.autorecovery.tls.secret.name" . }}"
    items:
    - key: tls.crt
      path: tls.crt
    - key: tls.key
      path: tls.key
- name: ca
  secret:
    secretName: "{{ template "pulsar.tls.ca.secret.name" . }}"
    items:
    - key: ca.crt
      path: ca.crt
{{- if .Values.tls.zookeeper.enabled }}
- name: keytool
  configMap:
    name: "{{ template "pulsar.fullname" . }}-keytool-configmap"
    defaultMode: 0755
{{- end }}
{{- end }}
{{- end }}

{{/*
Define autorecovery init container : verify cluster id
*/}}
{{- define "pulsar.autorecovery.init.verify_cluster_id" -}}
bin/apply-config-from-env.py conf/bookkeeper.conf;
{{- include "pulsar.autorecovery.zookeeper.tls.settings" . -}}
until bin/bookkeeper shell whatisinstanceid; do
  sleep 3;
done;
{{- end }}

{{/*
Define autorecovery log mounts
*/}}
{{- define "pulsar.autorecovery.log.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.autorecovery.component }}-log4j2"
  mountPath: "{{ template "pulsar.home" . }}/conf/log4j2.yaml"
  subPath: log4j2.yaml
{{- end }}

{{/*
Define autorecovery log volumes
*/}}
{{- define "pulsar.autorecovery.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.autorecovery.component }}-log4j2"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.autorecovery.component }}"
{{- end }}

{{/*
Define Autorecovery TLS certificate secret name
*/}}
{{- define "pulsar.autorecovery.tls.secret.name" -}}
{{- if .Values.tls.autorecovery.certSecretName -}}
{{- .Values.tls.autorecovery.certSecretName -}}
{{- else -}}
{{ .Release.Name }}-{{ .Values.tls.autorecovery.cert_name }}
{{- end -}}
{{- end -}}
