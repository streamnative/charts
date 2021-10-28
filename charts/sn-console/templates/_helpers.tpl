{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "sn_console.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand to the namespace streamnative console installs into.
*/}}
{{- define "sn_console.namespace" -}}
{{- default .Release.Namespace .Values.namespace -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sn_console.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sn_console.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the common labels.
*/}}
{{- define "sn_console.standardLabels" -}}
app: {{ template "sn_console.name" . }}
chart: {{ template "sn_console.chart" . }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
cluster: {{ template "sn_console.fullname" . }}
{{- end }}

{{/*
Create the template labels.
*/}}
{{- define "sn_console.template.labels" -}}
app: {{ template "sn_console.name" . }}
release: {{ .Release.Name }}
cluster: {{ template "sn_console.fullname" . }}
{{- end }}

{{/*
Create the match labels.
*/}}
{{- define "sn_console.matchLabels" -}}
app: {{ template "sn_console.name" . }}
release: {{ .Release.Name }}
{{- end }}

{{/*
Pulsar Cluster Name.
*/}}
{{- define "sn_console.cluster" -}}
{{- template "sn_console.fullname" . }}
{{- end }}