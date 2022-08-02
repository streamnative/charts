{{/* vim: set filetype=mustache: */}}

{{/*
pulsar home
*/}}
{{- define "pulsar.home" -}}
{{- if or (eq .Values.images.broker.repository "streamnative/platform") (eq .Values.images.broker.repository "streamnative/platform-all") }}
{{- print "/sn-platform" -}}
{{- else }}
{{- print "/pulsar" -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "pulsar.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand to the namespace pulsar installs into.
*/}}
{{- define "pulsar.namespace" -}}
{{- default .Release.Namespace .Values.namespace -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pulsar.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pulsar.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the common labels.
*/}}
{{- define "pulsar.standardLabels" -}}
app: {{ template "pulsar.name" . }}
chart: {{ template "pulsar.chart" . }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
cluster: {{ template "pulsar.fullname" . }}
{{- end }}

{{/*
Create the template labels.
*/}}
{{- define "pulsar.template.labels" -}}
app: {{ template "pulsar.name" . }}
release: {{ .Release.Name }}
cluster: {{ template "pulsar.fullname" . }}
{{- if .Values.istio.enabled }}
{{- if .Values.istio.labels }}
{{ toYaml .Values.istio.labels }}
{{- else }}
sidecar.istio.io/inject: "true"
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the match labels.
*/}}
{{- define "pulsar.matchLabels" -}}
app: {{ template "pulsar.name" . }}
release: {{ .Release.Name }}
{{- end }}

{{/*
Pulsar Cluster Name.
*/}}
{{- define "pulsar.cluster" -}}
{{- if .Values.pulsar_metadata.clusterName }}
{{- .Values.pulsar_metadata.clusterName }}
{{- else }}
{{- template "pulsar.fullname" . }}
{{- end }}
{{- end }}

{{/*
Istio gateway selector
*/}}
{{- define "pulsar.istio.gateway.selector" -}}
{{- if .Values.istio.gateway.selector }}
{{ toYaml .Values.istio.gateway.selector }}
{{- else }}
istio: ingressgateway
{{- end }}
{{- end }}

{{/*
Extra necessary Pod annotations in Istio mode
*/}}
{{- define "pulsar.istio.pod.annotations" -}}
{{- if .Values.istio.enabled -}}
prometheus.istio.io/merge-metrics: "false"
{{- end }}
{{- end -}}

{{/*
Define TLS CA secret name
*/}}
{{- define "pulsar.tls.ca.secret.name" -}}
{{- if .Values.tls.common.caSecretName -}}
{{- .Values.tls.common.caSecretName -}}
{{- else -}}
{{ .Release.Name }}-ca-tls
{{- end -}}
{{- end -}}

{{/*
JVM Options
*/}}
{{- define "pulsar.jvm.options" -}}
jvmOptions:
  memoryOptions:
  {{- if .configData.PULSAR_MEM }}
  - {{ .configData.PULSAR_MEM | quote }}
  {{- else }}
  {{- with .jvm.memoryOptions }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- end }}
  {{- if .configData.PULSAR_GC }}
  gcOptions:
  - {{ .configData.PULSAR_GC | quote }}
  {{- else }}
  {{- with .jvm.gcOptions }}
  gcOptions:
  {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- end }}
  {{- with .jvm.extraOptions }}
  extraOptions:
  {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .jvm.gcLoggingOptions }}
  gcLoggingOptions:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
Define function for save authenticaiton provider list
*/}}
{{- define "pulsar.authenticationProviders" }}
{{- $authenticationProviders := list -}}
{{- if .Values.auth.vault.enabled }}
{{- $authenticationProviders = append $authenticationProviders "io.streamnative.pulsar.broker.authentication.AuthenticationProviderOIDCToken" }}
{{- end }}
{{- if .Values.auth.authentication.tls.enabled }}
{{- $authenticationProviders = append $authenticationProviders "org.apache.pulsar.broker.authentication.AuthenticationProviderTls" }}
{{- end }}
{{- if .Values.auth.oauth.enabled }}
{{- $authenticationProviders = append $authenticationProviders "io.streamnative.pulsar.broker.authentication.AuthenticationProviderOAuth" }}
{{- end }}
{{- join "," (compact $authenticationProviders) | quote }}
{{- end }}

{{/*
Define function for save authenticaiton configuration
*/}}
{{- define "pulsar.autoConfiguration" }}
{{- if .Values.auth.vault.enabled }}
brokerClientAuthenticationPlugin: "org.apache.pulsar.client.impl.auth.AuthenticationToken"
PULSAR_PREFIX_chainAuthenticationEnabled: "true"
PULSAR_PREFIX_vaultHost: {{ template "pulsar.vault.url" . }}
{{- if .Values.broker.readPublicKeyFromFile }}
{{- if .Values.broker.publicKeyPath }}
PULSAR_PREFIX_OIDCPublicKeyPath: "file://{{ .Values.broker.publicKeyPath }}/publicKey"
{{- else }}
PULSAR_PREFIX_OIDCPublicKeyPath: "file:///pulsar/vault/v1/identity/oidc/.well-known/keys/publicKey"
{{- end }}
{{- else }}
PULSAR_PREFIX_OIDCPublicKeyPath: "{{ template "pulsar.vault.url" . }}/v1/identity/oidc/.well-known/keys"
{{- end }}
{{- end }}
{{- if .Values.auth.oauth.enabled }}
PULSAR_PREFIX_oauthIssuerUrl: "{{ .Values.auth.oauth.oauthIssuerUrl }}"
PULSAR_PREFIX_oauthAudience: "{{ .Values.auth.oauth.oauthAudience }}"
PULSAR_PREFIX_oauthSubjectClaim: "{{ .Values.auth.oauth.oauthSubjectClaim }}"
PULSAR_PREFIX_oauthAdminScope: "{{ .Values.auth.oauth.oauthAdminScope }}"
PULSAR_PREFIX_oauthScopeClaim: "{{ .Values.auth.oauth.oauthScopeClaim }}"
PULSAR_PREFIX_oauthAuthzRoleClaim: "{{ .Values.auth.oauth.oauthAuthzRoleClaim }}"
PULSAR_PREFIX_oauthAuthzAdminRole: "{{ .Values.auth.oauth.oauthAuthzAdminRole }}"
{{- if .Values.auth.oauth.brokerClientAuthenticationPlugin }}
brokerClientAuthenticationPlugin: "{{ .Values.auth.oauth.brokerClientAuthenticationPlugin }}"
{{- end }}
{{- if .Values.auth.oauth.brokerClientAuthenticationParameters }}
brokerClientAuthenticationParameters: "{{ .Values.auth.oauth.brokerClientAuthenticationParameters }}"
{{- end }}
{{- end }}
{{- end }}