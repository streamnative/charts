{{/* vim: set filetype=mustache: */}}

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
{{- if .Values.cluster -}}
{{- .Values.cluster | trunc 63 | trimSuffix "-" -}}
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

{{/*Define pulsar service url, the TCP port*/}}
{{- define "pulsar.serviceUrl" -}}
{{- if .Values.serviceUrl -}}
{{ .Values.serviceUrl -}}
{{- else -}}
pulsar://{{ template "pulsar.fullname" . }}-broker:6650/
{{- end -}}
{{- end -}}

{{/*Define pulsar webservice url, the admin API*/}}
{{- define "pulsar.webServiceUrl" -}}
{{- if .Values.webServiceUrl -}}
{{ .Values.webServiceUrl -}}
{{- else -}}
http://{{ template "pulsar.fullname" . }}-broker:8080/
{{- end -}}
{{- end -}}

{{/*Define pulsar zookeeper service url*/}}
{{- define "pulsar.zookeeperServiceUrl" -}}
{{- if .Values.zookeeperServiceUrl -}}
{{ .Values.zookeeperServiceUrl -}}
{{- else -}}
{{ template "pulsar.fullname" . }}-zookeeper:2181
{{- end -}}
{{- end -}}

{{/*Define pulsar broker service name*/}}
{{- define "pulsar.broker.serviceName" -}}
{{- if .Values.brokerServiceName -}}
{{ .Values.broker.brokerServiceName -}}
{{- else -}}
{{ template "pulsar.fullname" . }}-broker
{{- end -}}
{{- end -}}