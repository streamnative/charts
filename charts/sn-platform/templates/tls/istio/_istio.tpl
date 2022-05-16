{{/*
Define the Istio Ingress Gateway Root Namespace
*/}}
{{- define "istio.namespace" -}}
{{- default "istio-system" .Values.istio.gateway.rootNamespace -}}
{{- end -}}