{{/*
Define the pulsar bookkeeper service
*/}}
{{- define "pulsar.bookkeeper.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.bookkeeper.component }}
{{- end }}

{{/*
Define the bookkeeper hostname
*/}}
{{- define "pulsar.bookkeeper.hostname" -}}
${HOSTNAME}.{{ template "pulsar.bookkeeper.service" . }}.{{ template "pulsar.namespace" . }}.svc.cluster.local
{{- end -}}


{{/*
Define bookie zookeeper client tls settings
*/}}
{{- define "pulsar.bookkeeper.zookeeper.tls.settings" -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
/pulsar/keytool/keytool.sh bookie {{ template "pulsar.bookkeeper.hostname" . }} true;
{{- end }}
{{- end }}

{{- define "pulsar.bookkeeper.journal.pvc.name" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.bookkeeper.component }}-{{ .Values.bookkeeper.volumes.journal.name }}
{{- end }}

{{- define "pulsar.bookkeeper.ledgers.pvc.name" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.bookkeeper.component }}-{{ .Values.bookkeeper.volumes.ledgers.name }}
{{- end }}

{{- define "pulsar.bookkeeper.journal.storage.class" -}}
{{- if  .Values.bookkeeper.volumes.journal.storageClass }}
storageClassName: "{{ template "pulsar.bookkeeper.journal.pvc.name" . }}"
{{- else if .Values.bookkeeper.volumes.journal.storageClassName }}
storageClassName: "{{ .Values.bookkeeper.volumes.journal.storageClassName }}"
{{- end }}
{{- end }}

{{- define "pulsar.bookkeeper.ledgers.storage.class" -}}
{{- if  .Values.bookkeeper.volumes.ledgers.storageClass }}
storageClassName: "{{ template "pulsar.bookkeeper.ledgers.pvc.name" . }}"
{{- else if .Values.bookkeeper.volumes.ledgers.storageClassName }}
storageClassName: "{{ .Values.bookkeeper.volumes.ledgers.storageClassName }}"
{{- end }}
{{- end }}

{{/*
Define bookie tls certs mounts
*/}}
{{- define "pulsar.bookkeeper.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled (or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled) }}
- name: bookie-certs
  mountPath: "/pulsar/certs/bookie"
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
Define bookie tls certs volumes
*/}}
{{- define "pulsar.bookkeeper.certs.volumes" -}}
{{- if and .Values.tls.enabled (or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled) }}
- name: bookie-certs
  secret:
    secretName: "{{ template "pulsar.bookie.tls.secret.name" . }}"
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
Define bookie common config
*/}}
{{- define "pulsar.bookkeeper.config.common" -}}
zkServers: "{{ template "pulsar.zookeeper.connect" . }}"
zkLedgersRootPath: "{{ .Values.metadataPrefix }}/ledgers"
# enable bookkeeper http server
httpServerEnabled: "true"
httpServerPort: "{{ .Values.bookkeeper.ports.http }}"
# config the stats provider
statsProviderClass: org.apache.bookkeeper.stats.prometheus.PrometheusMetricsProvider
# use hostname as the bookie id
useHostNameAsBookieID: "true"
{{- end }}

{{/*
Define bookie tls config
*/}}
{{- define "pulsar.bookkeeper.config.tls" -}}
{{- if and .Values.tls.enabled .Values.tls.bookie.enabled }}
PULSAR_PREFIX_tlsProviderFactoryClass: org.apache.bookkeeper.tls.TLSContextFactory
PULSAR_PREFIX_tlsCertificatePath: /pulsar/certs/bookie/tls.crt
PULSAR_PREFIX_tlsKeyStoreType: PEM
PULSAR_PREFIX_tlsKeyStore: /pulsar/certs/bookie/tls.key
PULSAR_PREFIX_tlsTrustStoreType: PEM
PULSAR_PREFIX_tlsTrustStore: /pulsar/certs/ca/ca.crt
{{- end }}
{{- end }}

{{/*
Define bookie init container : verify cluster id
*/}}
{{- define "pulsar.bookkeeper.init.verify_cluster_id" -}}
{{- if not (and .Values.volumes.persistence .Values.bookkeeper.volumes.persistence) }}
bin/apply-config-from-env.py conf/bookkeeper.conf;
{{- include "pulsar.bookkeeper.zookeeper.tls.settings" . -}}
until bin/bookkeeper shell whatisinstanceid; do
  sleep 3;
done;
bin/bookkeeper shell bookieformat -nonInteractive -force -deleteCookie || true
{{- end }}
{{- if and .Values.volumes.persistence .Values.bookkeeper.volumes.persistence }}
set -e;
bin/apply-config-from-env.py conf/bookkeeper.conf;
{{- include "pulsar.bookkeeper.zookeeper.tls.settings" . -}}
until bin/bookkeeper shell whatisinstanceid; do
  sleep 3;
done;
{{- end }}
{{- end }}

{{/*
Define bookkeeper log mounts
*/}}
{{- define "pulsar.bookkeeper.log.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.bookkeeper.component }}-log4j2"
  mountPath: "{{ template "pulsar.home" .}}/conf/log4j2.yaml"
  subPath: log4j2.yaml
{{- end }}

{{/*
Define bookkeeper log volumes
*/}}
{{- define "pulsar.bookkeeper.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.bookkeeper.component }}-log4j2"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.bookkeeper.component }}"
{{- end }}

{{/*Define bookkeeper pod name*/}}
{{- define "pulsar.bookkeeper.podName" -}}
{{- print "bookie" -}}
{{- end -}}

{{/*Define bookkeeper datadog annotation*/}}
{{- define  "pulsar.bookkeeper.datadog.annotation" -}}
{{- if .Values.datadog.components.bookkeeper.enabled }}
ad.datadoghq.com/{{ template "pulsar.bookkeeper.podName" . }}.check_names: |
  ["openmetrics"]
ad.datadoghq.com/{{ template "pulsar.bookkeeper.podName" . }}.init_configs: |
  [{}]
ad.datadoghq.com/{{ template "pulsar.bookkeeper.podName" . }}.instances: |
  [
    {
      "prometheus_url": "http://%%host%%:{{ .Values.bookkeeper.ports.http }}/metrics",
      {{ if .Values.datadog.namespace -}}
      "namespace": "{{ .Values.datadog.namespace }}",
      {{ else -}}
      "namespace": "{{ template "pulsar.namespace" . }}",
      {{ end -}}
      "metrics": {{ .Values.datadog.components.bookkeeper.metrics }},
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
        "pulsar-bookie: {{ template "pulsar.fullname" . }}-{{ .Values.bookkeeper.component }}"
      ]
    }
  ]
{{- end }}
{{- end }}

{{/*Define bookkeeper service account*/}}
{{- define "pulsar.bookkeeper.serviceAccount" -}}
{{- if .Values.bookkeeper.serviceAccount.create -}}
    {{- if .Values.bookkeeper.serviceAccount.name -}}
{{ .Values.bookkeeper.serviceAccount.name }}
    {{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.bookkeeper.component }}-acct
    {{- end -}}
{{- else -}}
{{ .Values.bookkeeper.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Define Bookie TLS certificate secret name
*/}}
{{- define "pulsar.bookie.tls.secret.name" -}}
{{- if .Values.tls.bookie.certSecretName -}}
{{- .Values.tls.bookie.certSecretName -}}
{{- else -}}
{{ .Release.Name }}-{{ .Values.tls.bookie.cert_name }}
{{- end -}}
{{- end -}}
