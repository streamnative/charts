{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "promtail.name" -}}
{{- default .Chart.Name .Values.promtail.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "promtail.fullname" -}}
{{- if .Values.promtail.fullnameOverride -}}
{{- .Values.promtail.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.promtail.nameOverride -}}
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
{{- define "promtail.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account
*/}}
{{- define "promtail.serviceAccountName" -}}
{{- if .Values.promtail.serviceAccount.create -}}
    {{ default (include "promtail.fullname" .) .Values.promtail.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.promtail.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
The service name to connect to Loki. Defaults to the same logic as "loki.fullname"
*/}}
{{- define "loki.serviceName" -}}
{{- if .Values.promtail.loki.serviceName -}}
{{- .Values.promtail.loki.serviceName -}}
{{- else if .Values.promtail.loki.fullnameOverride -}}
{{- .Values.promtail.loki.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "loki" .Values.promtail.loki.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

