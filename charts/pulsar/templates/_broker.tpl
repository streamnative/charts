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
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
/pulsar/keytool/keytool.sh broker {{ template "pulsar.broker.hostname" . }} true;
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
{{- if .Values.tls.zookeeper.enabled }}
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
    secretName: "{{ template "pulsar.fullname" . }}-{{ .Values.tls.broker.cert_name }}"
    items:
    - key: tls.crt
      path: tls.crt
    - key: tls.key
      path: tls.key
- name: ca
  secret:
    secretName: "{{ template "pulsar.fullname" . }}-ca-tls"
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
- mountPath: "/logconf"
  name: "{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}-log4j-config"
{{- end }}

{{/*
Define broker log volumes
*/}}
{{- define "pulsar.broker.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}-log4j-config"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}"
    items:
    - key: log4j2.yaml
      path: conf/log4j2.yaml
{{- end }}
