{{/*
Define the Istio Ingress Gateway Root Namespace
*/}}
{{- define "istio.gateway.namespace" -}}
{{- default "istio-system" .Values.istio.gateway.namespace -}}
{{- end -}}