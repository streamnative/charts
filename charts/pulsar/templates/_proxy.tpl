{{/*
Define proxy token mounts
*/}}
{{- define "pulsar.proxy.token.volumeMounts" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
- mountPath: "/pulsar/keys"
  name: token-keys
  readOnly: true
- mountPath: "/pulsar/tokens"
  name: proxy-token
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define proxy token volumes
*/}}
{{- define "pulsar.proxy.token.volumes" -}}
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
      {{- end}}
- name: proxy-token
  secret:
    secretName: "{{ .Release.Name }}-token-{{ .Values.auth.superUsers.proxy }}"
    items:
      - key: TOKEN
        path: proxy/token
{{- end }}
{{- end }}
{{- end }}

{{/*
Define proxy certs mounts
*/}}
{{- define "pulsar.proxy.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled (or .Values.tls.proxy.enabled .Values.tls.broker.enabled) }}
{{- if .Values.tls.proxy.enabled }}
- mountPath: "/pulsar/certs/proxy"
  name: proxy-certs
  readOnly: true
{{- end }}
{{- if .Values.tls.enabled }}
- mountPath: "/pulsar/certs/ca"
  name: ca
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define proxy certs volumes
*/}}
{{- define "pulsar.proxy.certs.volumes" -}}
{{- if and .Values.tls.enabled .Values.tls.proxy.enabled }}
- name: ca
  secret:
  {{- if and .Values.certs.public_issuer.enabled (eq .Values.certs.public_issuer.type "acme") }}
    secretName: {{ .Values.certs.lets_encrypt.ca_ref.secretName }}
    items:
      - key: {{ .Values.certs.lets_encrypt.ca_ref.keyName }}
        path: ca.crt
  {{- else }}
    secretName: "{{ template "pulsar.fullname" . }}-ca-tls"
    items:
      - key: ca.crt
        path: ca.crt
  {{- end }}
- name: proxy-certs
  secret:
    secretName: "{{ template "pulsar.fullname" . }}-{{ .Values.tls.proxy.cert_name }}"
    items:
      - key: tls.crt
        path: tls.crt
      - key: tls.key
        path: tls.key
{{- end }}
{{- end }}

{{/*
Define proxy log mounts
*/}}
{{- define "pulsar.proxy.log.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}"
  mountPath: "{{ template "pulsar.home" . }}/conf/log4j2.yaml"
  subPath: log4j2.yaml
{{- end }}

{{/*
Define proxy log volumes
*/}}
{{- define "pulsar.proxy.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}"
{{- end }}
