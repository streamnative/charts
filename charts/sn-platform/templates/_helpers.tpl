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
