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
{{- if .Values.istio.mergeMetrics -}}
prometheus.istio.io/merge-metrics: "true"
{{- else -}}
prometheus.istio.io/merge-metrics: "false"
{{- end -}}
{{- end -}}
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
{{- if .Values.auth.authentication.jwt.enabled }}
{{- $authenticationProviders = append $authenticationProviders "org.apache.pulsar.broker.authentication.AuthenticationProviderToken" }}
{{- end }}
{{- join "," (compact $authenticationProviders) | quote }}
{{- end }}

{{/*
Define function for save authorization provider
*/}}
{{- define "pulsar.authorizationProvider" }}
authorizationEnabled: "true"
{{- if .Values.auth.oauth.enabled }}
authorizationProvider: {{ .Values.auth.oauth.authorizationProvider | default "io.streamnative.pulsar.broker.authorization.AuthorizationProviderOAuth" }}
{{- else }}
authorizationProvider: "org.apache.pulsar.broker.authorization.PulsarAuthorizationProvider"
{{- end }}
{{- end }}

{{/*
Define function for save authenticaiton configuration
*/}}
{{- define "pulsar.authConfiguration" }}
{{- if .Values.auth.vault.enabled }}
brokerClientAuthenticationPlugin: "org.apache.pulsar.client.impl.auth.AuthenticationToken"
PULSAR_PREFIX_chainAuthenticationEnabled: "true"
PULSAR_PREFIX_vaultHost: {{ template "pulsar.vault.url" . }}
{{- if .Values.broker.readPublicKeyFromFile }}
PULSAR_PREFIX_OIDCPublicKeyPath: file://{{ .Values.broker.publicKeyPath | default "/pulsar/vault/v1/identity/oidc/.well-known/keys" }}/publicKey
{{- else }}
PULSAR_PREFIX_OIDCPublicKeyPath: "{{ template "pulsar.vault.url" . }}/v1/identity/oidc/.well-known/keys"
{{- end }}
{{- end }}
{{- if .Values.auth.oauth.enabled }}
PULSAR_PREFIX_oauthIssuerUrl: "{{ .Values.auth.oauth.oauthIssuerUrl }}"
PULSAR_PREFIX_oauthAudience: "{{ .Values.auth.oauth.oauthAudience }}"
{{- if .Values.auth.oauth.oauthAdminScope }}
PULSAR_PREFIX_oauthAdminScope: "{{ .Values.auth.oauth.oauthAdminScope }}"
{{- end }}
PULSAR_PREFIX_oauthScopeClaim: "{{ .Values.auth.oauth.oauthScopeClaim }}"
{{- if .Values.auth.oauth.oauthAuthzRoleClaim }}
PULSAR_PREFIX_oauthAuthzRoleClaim: "{{ .Values.auth.oauth.oauthAuthzRoleClaim }}"
{{- end }}
{{- if .Values.auth.oauth.oauthAuthzAdminRole }}
PULSAR_PREFIX_oauthAuthzAdminRole: "{{ .Values.auth.oauth.oauthAuthzAdminRole }}"
{{- end }}
brokerClientAuthenticationPlugin: {{ .Values.auth.oauth.brokerClientAuthenticationPlugin | default "org.apache.pulsar.client.impl.auth.oauth2.AuthenticationOAuth2" }}
{{- if .Values.auth.oauth.brokerClientAuthenticationParameters }}
brokerClientAuthenticationParameters: '{{ .Values.auth.oauth.brokerClientAuthenticationParameters | toJson }}'
{{- end }}
{{- if .Values.auth.oauth.oauthSubjectClaim }}
PULSAR_PREFIX_oauthSubjectClaim: "{{ .Values.auth.oauth.oauthSubjectClaim }}"
{{- end }}
{{- end }}
{{- if .Values.auth.authentication.jwt.enabled }}
brokerClientAuthenticationPlugin: "org.apache.pulsar.client.impl.auth.AuthenticationToken"
{{- end }}
{{- end }}

{{/*
Define function for get authenticaiton environment variable
*/}}
{{- define "pulsar.authEnvironment" }}
{{- if .Values.auth.vault.enabled }}
- name: PULSAR_PREFIX_OIDCTokenAudienceID
  valueFrom:
      secretKeyRef:
        name: {{ template "pulsar.vault-secret-key-name" . }}
        key: PULSAR_PREFIX_OIDCTokenAudienceID
{{- if and (eq .Component "proxy") .Values.auth.superUsers.proxyRolesEnabled }}
- name: brokerClientAuthenticationParameters
  valueFrom:
      secretKeyRef:
        name: {{ template "pulsar.vault-secret-key-name" . }}
        key: PROXY_brokerClientAuthenticationParameters
{{- else }}
- name: brokerClientAuthenticationParameters
  valueFrom:
      secretKeyRef:
        name: {{ template "pulsar.vault-secret-key-name" . }}
        key: brokerClientAuthenticationParameters
{{- end }}
{{- end }}
{{- if .Values.auth.authentication.jwt.enabled }}
{{- if and (eq .Component "proxy") .Values.auth.superUsers.proxyRolesEnabled }}
- name: brokerClientAuthenticationParameters
  valueFrom:
      secretKeyRef:
        name: {{ .Release.Name }}-token-proxy-admin
        key: TOKEN
{{- else }}
- name: brokerClientAuthenticationParameters
  valueFrom:
      secretKeyRef:
        name: {{ .Release.Name }}-token-admin
        key: TOKEN
{{- end }}
{{- if .Values.auth.authentication.jwt.usingSecretKey }}
- name: tokenSecretKey
  value: "file:///mnt/secrets/SECRETKEY"
{{- else }}
- name: tokenPublicKey
  value: "file:///mnt/secrets/PUBLICKEY"
{{- end }}
{{- end }}
{{- end }}

{{/*
Define function for get authenticaiton secret
*/}}
{{- define "pulsar.authSecret" }}
{{- if .Values.auth.authentication.enabled }}
{{- if and .Values.auth.oauth.enabled .Values.auth.oauth.brokerClientCredentialSecret }}
- mountPath: /mnt/secrets
  secretName: "{{ .Values.auth.oauth.brokerClientCredentialSecret }}"
{{- end }}
{{- if .Values.auth.authentication.jwt.enabled }}
{{- if .Values.auth.authentication.jwt.usingSecretKey }}
- mountPath: /mnt/secrets
  secretName: {{ .Release.Name }}-token-symmetric-key
{{- else }}
- mountPath: /mnt/secrets
  secretName: {{ .Release.Name }}-token-asymmetric-key
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
AntiAffinity Rules
*/}}
{{- define "pulsar.antiAffinityRules" }}
{{- if not .thisAffinity.customRules }}
{{- if and .Values.affinity.anti_affinity .thisAffinity.anti_affinity }}
podAntiAffinity:
  {{ .thisAffinity.type }}:
    {{ if eq .thisAffinity.type "requiredDuringSchedulingIgnoredDuringExecution" }}
    - labelSelector:
        matchExpressions:
          - key: "app"
            operator: In
            values:
              - "{{ template "pulsar.name" . }}"
          - key: "release"
            operator: In
            values:
              - {{ .Release.Name }}
          - key: "component"
            operator: In
            values:
              - {{ .Component }}
      topologyKey: "kubernetes.io/hostname"
      {{ if and .Values.affinity.zone_anti_affinity .thisAffinity.zone_anti_affinity }}
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: {{ .thisAffinity.zone_anti_affinity_weight | default .Values.affinity.zone_anti_affinity_weight }}
      podAffinityTerm:
        labelSelector:
          matchExpressions:
            - key: "app"
              operator: In
              values:
                - "{{ template "pulsar.name" . }}"
            - key: "release"
              operator: In
              values:
                - {{ .Release.Name }}
            - key: "component"
              operator: In
              values:
                - {{ .Component }}
        topologyKey: "topology.kubernetes.io/zone"
      {{end}}
    {{ else }}
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
            - key: "app"
              operator: In
              values:
                - "{{ template "pulsar.name" . }}"
            - key: "release"
              operator: In
              values:
                - {{ .Release.Name }}
            - key: "component"
              operator: In
              values:
                - {{ .Component }}
        topologyKey: "kubernetes.io/hostname"
      {{ if and .Values.affinity.zone_anti_affinity .thisAffinity.zone_anti_affinity }}
    - weight: {{ .thisAffinity.zone_anti_affinity_weight | default .Values.affinity.zone_anti_affinity_weight }}
      podAffinityTerm:
        labelSelector:
          matchExpressions:
            - key: "app"
              operator: In
              values:
                - "{{ template "pulsar.name" . }}"
            - key: "release"
              operator: In
              values:
                - {{ .Release.Name }}
            - key: "component"
              operator: In
              values:
                - {{ .Component }}
        topologyKey: "topology.kubernetes.io/zone"
      {{end}}
    {{ end }}
{{- end }}
{{- else }}
{{ toYaml .thisAffinity.customRules }}
{{- end }}
{{end}}
