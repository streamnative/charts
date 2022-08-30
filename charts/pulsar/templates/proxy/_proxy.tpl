{{/*
pulsar service domain
*/}}
{{- define "pulsar.service_domain" -}}
{{- if .Values.ingress.proxy.externalDomainOverride -}}
{{ .Values.ingress.proxy.externalDomainOverride }}
{{- else -}}
{{- if .Values.ingress.proxy.enabled -}}
  {{- if .Values.ingress.proxy.external_domain }}
{{- print .Values.ingress.proxy.external_domain -}}
    {{- else -}}
      {{- if .Values.domain.enabled -}}
{{- printf "data.%s.%s" .Release.Name .Values.domain.suffix -}}
      {{- else -}}
{{- print "" -}}
      {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Define proxy token mounts
*/}}
{{- define "pulsar.proxy.token.volumeMounts" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
{{- if not .Values.auth.vault.enabled }}
- mountPath: "/pulsar/keys"
  name: token-keys
  readOnly: true
{{- end }}
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
      {{- end}}
{{- end }}
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
{{- if .Values.tls.proxy.untrustedCa }}
- mountPath: "/pulsar/certs/ca"
  name: proxy-ca
  readOnly: true
{{- end }}
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
{{- if .Values.tls.proxy.untrustedCa }}
- name: proxy-ca
  secret:
  {{- if and .Values.certs.public_issuer.enabled (eq .Values.certs.public_issuer.type "acme") }}
    secretName: {{ .Values.certs.lets_encrypt.ca_ref.secretName }}
    items:
      - key: {{ .Values.certs.lets_encrypt.ca_ref.keyName }}
        path: ca.crt
  {{- else }}
    secretName: "{{ template "pulsar.tls.ca.secret.name" . }}"
    items:
      - key: ca.crt
        path: ca.crt
  {{- end }}
  {{- end }}
- name: proxy-certs
  secret:
    secretName: "{{ template "pulsar.proxy.tls.secret.name" . }}"
    items:
      - key: tls.crt
        path: tls.crt
      - key: tls.key
        path: tls.key
{{- end }}
{{- if and .Values.tls.enabled .Values.tls.broker.enabled }}
- name: broker-ca
  secret:
    secretName: "{{ template "pulsar.tls.ca.secret.name" . }}"
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
{{- if .Values.datadog.components.proxy.enabled }}
{{- if eq (.Values.datadog.components.proxy.checkType | default "openmetrics") "openmetrics" }}
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.check_names: |
  ["openmetrics"]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.init_configs: |
  [{}]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.instances: |
  [
    {
      "prometheus_url": "http://%%host%%:{{ .Values.proxy.ports.http }}/metrics/",
      "namespace": "{{ .Values.datadog.namespace }}",
      "metrics": {{ .Values.datadog.components.proxy.metrics }},
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
{{- else if (.Values.datadog.components.proxy.checkType | default "openmetrics") "native" }}
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.check_names: |
  ["pulsar"]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.init_configs: |
  [{}]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.instances: |
  [
    {
      "openmetrics_endpoint": "http://%%host%%:{{ .Values.proxy.ports.http }}/metrics/",
      "enable_health_service_check": true,
      "timeout": 300,
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
{{- else if (.Values.datadog.components.proxy.checkType | default "openmetrics") "both" }}
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.check_names: |
  ["openmetrics", "pulsar"]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.init_configs: |
  [{}, {}]
ad.datadoghq.com/{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.instances: |
  [
    {
      "prometheus_url": "http://%%host%%:{{ .Values.proxy.ports.http }}/metrics/",
      "namespace": "{{ .Values.datadog.namespace }}",
      "metrics": {{ .Values.datadog.components.proxy.metrics }},
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
    },
    {
      "openmetrics_endpoint": "http://%%host%%:{{ .Values.proxy.ports.http }}/metrics/",
      "enable_health_service_check": true,
      "timeout": 300,
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
{{- end }}
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

{{/*
pulsar ingress target port for websocket endpoint
*/}}
{{- define "pulsar.proxy.ingress.targetPort.websocket" -}}
{{- if and .Values.tls.enabled .Values.tls.proxy.enabled }}
{{- print "websockettls" -}}
{{- else -}}
{{- print "websocket" -}}
{{- end -}}
{{- end -}}

{{/*
Pulsar Broker Service URL
*/}}
{{- define "pulsar.proxy.broker.service.url" -}}
{{- if .Values.proxy.brokerServiceURL -}}
{{- .Values.proxy.brokerServiceURL -}}
{{- else -}}
pulsar://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}:{{ .Values.broker.ports.pulsar }}
{{- end -}}
{{- end -}}

{{/*
Pulsar Web Service URL
*/}}
{{- define "pulsar.proxy.web.service.url" -}}
{{- if .Values.proxy.brokerWebServiceURL -}}
{{- .Values.proxy.brokerWebServiceURL -}}
{{- else -}}
http://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}:{{ .Values.broker.ports.http }}
{{- end -}}
{{- end -}}

{{/*
Pulsar Broker Service URL TLS
*/}}
{{- define "pulsar.proxy.broker.service.url.tls" -}}
{{- if .Values.proxy.brokerServiceURLTLS -}}
{{- .Values.proxy.brokerServiceURLTLS -}}
{{- else -}}
pulsar+ssl://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}:{{ .Values.broker.ports.pulsarssl }}
{{- end -}}
{{- end -}}

{{/*
Pulsar Web Service URL
*/}}
{{- define "pulsar.proxy.web.service.url.tls" -}}
{{- if .Values.proxy.brokerWebServiceURLTLS -}}
{{- .Values.proxy.brokerWebServiceURLTLS -}}
{{- else -}}
https://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}:{{ .Values.broker.ports.https }}
{{- end -}}
{{- end -}}

{{/*
Pulsar Function Service URL
*/}}
{{- define "pulsar.proxy.function.service.url" -}}
http://{{ template "pulsar.fullname" . }}-{{ .Values.functions.component }}:{{ .Values.functions.ports.http }}
{{- end -}}

{{/*
Pulsar Function Service URL TLS
*/}}
{{- define "pulsar.proxy.function.service.url.tls" -}}
https://{{ template "pulsar.fullname" . }}-{{ .Values.functions.component }}:{{ .Values.functions.ports.https }}
{{- end -}}

{{/*Define proxy service account*/}}
{{- define "pulsar.proxy.serviceAccount" -}}
{{- if .Values.proxy.serviceAccount.create -}}
    {{- if .Values.proxy.serviceAccount.name -}}
{{ .Values.proxy.serviceAccount.name }}
    {{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}-acct
    {{- end -}}
{{- else -}}
{{ .Values.proxy.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Define Proxy TLS certificate secret name
*/}}
{{- define "pulsar.proxy.tls.secret.name" -}}
{{- if .Values.tls.proxy.certSecretName -}}
{{- .Values.tls.proxy.certSecretName -}}
{{- else -}}
{{ .Release.Name }}-{{ .Values.tls.proxy.cert_name }}
{{- end -}}
{{- end -}}


{{/*
Define Proxy oauth2 mounts
*/}}
{{- define "pulsar.proxy.oauth2.volumeMounts" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "oauth2" }}
- mountPath: "/pulsar/oauth2"
  name: proxy-oauth2
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define Proxy oauth2 volumes
*/}}
{{- define "pulsar.proxy.oauth2.volumes" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "oauth2" }}
- name: proxy-oauth2
  secret:
    secretName: "{{ .Release.Name }}-oauth2-private-key"
    items:
      - key: auth.json
        path: auth.json
{{- end }}
{{- end }}
{{- end }}
