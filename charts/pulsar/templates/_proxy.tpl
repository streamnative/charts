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
- mountPath: "/pulsar/certs/ca"
  name: proxy-ca
  readOnly: true
{{- end }}
{{- if .Values.tls.broker.enabled }}
- mountPath: "/pulsar/certs/broker"
  name: broker-ca
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define proxy certs volumes
*/}}
{{- define "pulsar.proxy.certs.volumes" -}}
{{- if and .Values.tls.enabled .Values.tls.proxy.enabled }}
- name: proxy-ca
  secret:
  {{- if and .Values.certs.public_issuer.enabled (eq .Values.certs.public_issuer.type "acme") }}
    secretName: {{ .Values.certs.lets_encrypt.ca_ref.secretName }}
    items:
      - key: {{ .Values.certs.lets_encrypt.ca_ref.keyName }}
        path: ca.crt
  {{- else }}
    secretName: "{{ .Release.Name }}-ca-tls"
    items:
      - key: ca.crt
        path: ca.crt
  {{- end }}
- name: proxy-certs
  secret:
    secretName: "{{ .Release.Name }}-{{ .Values.tls.proxy.cert_name }}"
    items:
      - key: tls.crt
        path: tls.crt
      - key: tls.key
        path: tls.key
{{- end }}
{{- if and .Values.tls.enabled .Values.tls.broker.enabled }}
- name: broker-ca
  secret:
    secretName: "{{ .Release.Name }}-ca-tls"
    items:
      - key: ca.crt
        path: ca.crt
{{- end }}
{{- end }}

{{/*
Define proxy log mounts
*/}}
{{- define "pulsar.proxy.log.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}-log4j2"
  mountPath: "{{ template "pulsar.home" . }}/conf/log4j2.yaml"
  subPath: log4j2.yaml
{{- end }}

{{/*
Define proxy log volumes
*/}}
{{- define "pulsar.proxy.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}-log4j2"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}"
{{- end }}
{{/*
Define proxy datadog annotation
*/}}
{{- define "pulsar.proxy.datadog.annotation" -}}
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.check_names: |
  ["openmetrics"]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.init_configs: |
  [{}]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.instances: |
  [
    {
      "prometheus_url": "http://%%host%%:{{ .Values.proxy.ports.http }}/metrics/",
      "namespace": "{{ .Values.datadog.namespace }}",
      "metrics": {{ .Values.datadog.metrics }},
      "health_service_check": true,
      "prometheus_timeout": 1000,
      "max_returned_metrics": 1000000,
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
      "extra_headers": {
          "Authorization": "Bearer %%env_PROXY_TOKEN%%"
      },
{{- end }}
{{- end }}
      "tags": [
        "pulsar-proxy: {{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}"
      ]
    }
  ]
{{- end }}

{{/*
pulsar ingress target port for http endpoint
*/}}
{{- define "pulsar.proxy.ingress.targetPort.admin" -}}
{{- if and .Values.tls.enabled .Values.tls.proxy.enabled }}
{{- print "https" -}}
{{- else -}}
{{- print "http" -}}
{{- end -}}
{{- end -}}

{{/*
pulsar ingress target port for http endpoint
*/}}
{{- define "pulsar.proxy.ingress.targetPort.data" -}}
{{- if and .Values.tls.enabled .Values.tls.proxy.enabled }}
{{- print "pulsarssl" -}}
{{- else -}}
{{- print "pulsar" -}}
{{- end -}}
{{- end -}}
