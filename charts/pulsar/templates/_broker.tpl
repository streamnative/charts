{{/*
Define the pulsar brroker service
*/}}
{{- define "pulsar.broker.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}
{{- end }}

{{/*
Define the hostname
*/}}
{{- define "pulsar.broker.hostname" -}}
${HOSTNAME}.{{ template "pulsar.broker.service" . }}.{{ .Values.namespace }}.svc.cluster.local
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
- mountPath: "/pulsar/keys"
  name: token-keys
  readOnly: true
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
