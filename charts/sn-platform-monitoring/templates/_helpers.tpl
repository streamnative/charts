{{/* vim: set filetype=mustache: */}}

{{/*
pulsar home
*/}}
{{- define "pulsar.home" -}}
{{- print "/sn-platform" -}}
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
control center domain
*/}}
{{- define "pulsar.control_center_domain" -}}
{{- if .Values.ingress.control_center.enabled -}}
    {{- if .Values.ingress.control_center.external_domain }}
{{- printf "%s" .Values.ingress.control_center.external_domain -}}
    {{- else -}}
{{- printf "admin.%s.%s" .Release.Name .Values.domain.suffix -}}
    {{- end -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}

{{/*
control center url
*/}}
{{- define "pulsar.control_center_url" -}}
{{- if .Values.ingress.control_center.enabled -}}
    {{- if .Values.ingress.control_center.external_domain }}
{{- printf "%s%s" .Values.ingress.control_center.external_domain_scheme .Values.ingress.control_center.external_domain -}}
    {{- else -}}
        {{- if .Values.domain.enabled }}
            {{- if .Values.ingress.control_center.tls.enabled }}
{{- printf "https://admin.%s.%s" .Release.Name .Values.domain.suffix -}}
            {{- else -}}
{{- printf "http://admin.%s.%s" .Release.Name .Values.domain.suffix -}}
            {{- end -}}
        {{- else -}}
{{- printf "" -}}
        {{- end -}}
    {{- end -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}

{{/*
control center path: alert manager
*/}}
{{- define "pulsar.control_center_path.alertmanager" -}}
{{- if and .Values.ingress.control_center.enabled .Values.ingress.control_center.endpoints.alertmanager -}}
{{- print "/alerts" -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}

{{/*
control center path: grafana
*/}}
{{- define "pulsar.control_center_path.grafana" -}}
{{- if and .Values.ingress.control_center.enabled .Values.ingress.control_center.endpoints.grafana -}}
{{- print "/grafana" -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}

{{/*
control center path: prometheus
*/}}
{{- define "pulsar.control_center_path.prometheus" -}}
{{- if and .Values.ingress.control_center.enabled .Values.ingress.control_center.endpoints.prometheus -}}
{{- print "/prometheus" -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}

{{/*
pulsar controller ingress target port for http endpoint
*/}}
{{- define "pulsar.control_center.ingress.targetPort" -}}
{{- if and .Values.ingress.control_center.tls.enabled (not .Values.ingress.controller.tls.termination) }}
{{- print "https" -}}
{{- else -}}
{{- print "http" -}}
{{- end -}}
{{- end -}}
