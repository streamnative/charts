{{/*
The namespace to run functions
*/}}
{{- define "pulsar.functions.namespace" -}}
{{- if .Values.functions.jobNamespace }}
{{- .Values.functions.jobNamespace }}
{{- else }}
{{- template "pulsar.namespace" . }}
{{- end }}
{{- end }}

{{/*
The pulsar root directory of functions image
*/}}
{{- define "pulsar.functions.pulsarRootDir" -}}
{{- if .Values.functions.pulsarRootDir }}
{{- .Values.functions.pulsarRootDir }}
{{- else }}
{{- template "pulsar.home" . }}
{{- end }}
{{- end }}

{{/*
The customWorkerConfig tpl
*/}}
{{- define "pulsar.functions.config.customWorkerConfig" -}}
functionsWorkerServiceCustomConfigs:
{{- if and .Values.broker.functionmesh.enabled (eq .Values.broker.functionmesh.builtinConnectorType "ConnectorCatalog") }}
  connectorCatalogNamespace: "{{ template "pulsar.namespace" . }}"
{{- end }}
{{- end }}

{{/*
Merge customWorkerConfig tpl
*/}}
{{- define "pulsar.functions.config.mergedCustomWorkerConfig" -}}
{{- $baseCustomWorkerConfig := include "pulsar.functions.config.customWorkerConfig" . | fromYaml -}}
{{- if .Values.broker.functionmesh.customWorkerConfig }}
{{- $dictCustomWorkerConfig := .Values.broker.functionmesh.customWorkerConfig | fromYaml -}}
{{- $mergedConfig := mustMergeOverwrite (dict) $dictCustomWorkerConfig $baseCustomWorkerConfig -}}
{{ toYaml $dictCustomWorkerConfig | quote }}
{{- else -}}
{{ $baseCustomWorkerConfig | toYaml | quote }}
{{- end }}
{{- end }}
