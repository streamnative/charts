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
{{- else if and .Values.tls.enabled .Values.tls.zookeeper.enabled -}} 
{{ template "pulsar.zookeeper.service" . }}:{{ .Values.zookeeper.ports.clientTls }}
{{- else -}}
{{ template "pulsar.zookeeper.service" . }}:{{ .Values.zookeeper.ports.client }}
{{- end -}}
{{- end -}}

{{/*
Define the pulsar configurationStore
*/}}
{{- define "pulsar.configurationStore.connect" -}}
{{$configurationStore:=.Values.pulsar_metadata.configurationStoreServers}}
{{- if and (not .Values.components.zookeeper) $configurationStore }}
{{- $configurationStore -}}
{{- else if and .Values.tls.enabled .Values.tls.zookeeper.enabled -}} 
{{ template "pulsar.zookeeper.service" . }}:{{ .Values.zookeeper.ports.clientTls }}
{{- else -}}
{{ template "pulsar.zookeeper.service" . }}:{{ .Values.zookeeper.ports.client }}
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
    secretName: "{{ template "pulsar.zookeeper.tls.secret.name" . }}"
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
- name: keytool
  configMap:
    name: "{{ template "pulsar.fullname" . }}-keytool-configmap"
    defaultMode: 0755
{{- end}}
{{- end }}

{{/*Define zookeeper pod name*/}}
{{- define "pulsar.zookeeper.podName" -}}
{{- print "zookeeper" -}}
{{- end -}}

{{/*Define zookeeper datadog annotation*/}}
{{- define "pulsar.zookeeper.datadog.annotation"}}
{{- if .Values.datadog.components.zookeeper.enabled }}
{{- if eq .Values.datadog.adVersion "v1" }}
ad.datadoghq.com/{{ template "pulsar.zookeeper.podName" . }}.check_names: |
  ["openmetrics"]
ad.datadoghq.com/{{ template "pulsar.zookeeper.podName" . }}.init_configs: |
  [{}]
ad.datadoghq.com/{{ template "pulsar.zookeeper.podName" . }}.instances: |
  [
    {
      "openmetrics_endpoint": "http://%%host%%:{{ .Values.zookeeper.ports.metrics }}/metrics",
      {{ if .Values.datadog.namespace -}}
      "namespace": "{{ .Values.datadog.namespace }}",
      {{ else -}}
      "namespace": "{{ template "pulsar.namespace" . }}",
      {{ end -}}
      "metrics": {{ .Values.datadog.components.zookeeper.metrics }},
      {{- range $key, $value := .Values.datadog.components.zookeeper.custom_instance_configs }}
      {{ $key | quote }}: {{ $value }},
      {{- end }}
      "enable_health_service_check": true,
      "timeout": 1000,
      "tags": [
        "pulsar-zookeeper: {{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}"
      ]
    }
  ]
{{- end }}
{{- if eq .Values.datadog.adVersion "v2" }}
ad.datadoghq.com/{{ template "pulsar.zookeeper.podName" . }}.checks: |
  {
    "openmetrics": {
      "init_config": {},
      "instances": [
    {
      "openmetrics_endpoint": "http://%%host%%:{{ .Values.zookeeper.ports.metrics }}/metrics",
      {{ if .Values.datadog.namespace -}}
      "namespace": "{{ .Values.datadog.namespace }}",
      {{ else -}}
      "namespace": "{{ template "pulsar.namespace" . }}",
      {{ end -}}
      "metrics": {{ .Values.datadog.components.zookeeper.metrics }},
      {{- range $key, $value := .Values.datadog.components.zookeeper.custom_instance_configs }}
      {{ $key | quote }}: {{ $value }},
      {{- end }}
      "enable_health_service_check": true,
      "timeout": 1000,
      "tags": [
        "pulsar-zookeeper: {{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}"
      ]
    }
  ]
    }
  }
{{- end }}
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

{{- define "pulsar.zookeeper.data.storage.class" -}}
{{- if  .Values.zookeeper.volumes.data.storageClass }}
storageClassName: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.data.name }}"
{{- else if .Values.zookeeper.volumes.data.storageClassName }}
storageClassName: {{ .Values.zookeeper.volumes.data.storageClassName }}
{{- end }}
{{- end }}

{{- define "pulsar.zookeeper.dataLog.storage.class" -}}
{{- if  .Values.zookeeper.volumes.dataLog.storageClass }}
storageClassName: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.dataLog.name }}"
{{- else if .Values.zookeeper.volumes.dataLog.storageClassName }}
storageClassName: {{ .Values.zookeeper.volumes.dataLog.storageClassName }}
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
  {{- if  .Values.zookeeper.volumes.data.storageClass }}
    storageClassName: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.data.name }}"
  {{- else if .Values.zookeeper.volumes.data.storageClassName }}
    storageClassName: {{ .Values.zookeeper.volumes.data.storageClassName }}
  {{- end }}
{{- if .Values.zookeeper.volumes.useSeparateDiskForTxlog }}
- metadata:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.dataLog.name }}"
  spec:
    accessModes: [ "ReadWriteOnce" ]
    resources:
      requests:
        storage: {{ .Values.zookeeper.volumes.dataLog.size }}
  {{- if  .Values.zookeeper.volumes.dataLog.storageClass }}
    storageClassName: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-{{ .Values.zookeeper.volumes.dataLog.name }}"
  {{- else if .Values.zookeeper.volumes.dataLog.storageClassName }}
    storageClassName: {{ .Values.zookeeper.volumes.dataLog.storageClassName }}
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

{{/*Define zookeeper service account*/}}
{{- define "pulsar.zookeeper.serviceAccount" -}}
{{- if .Values.zookeeper.serviceAccount.create -}}
    {{- if .Values.zookeeper.serviceAccount.name -}}
{{ .Values.zookeeper.serviceAccount.name }}
    {{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}-acct
    {{- end -}}
{{- else -}}
{{ .Values.zookeeper.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Define ZooKeeper TLS certificate secret name
*/}}
{{- define "pulsar.zookeeper.tls.secret.name" -}}
{{- if .Values.tls.zookeeper.certSecretName -}}
{{- .Values.tls.zookeeper.certSecretName -}}
{{- else -}}
{{ .Release.Name }}-{{ .Values.tls.zookeeper.cert_name }}
{{- end -}}
{{- end -}}
