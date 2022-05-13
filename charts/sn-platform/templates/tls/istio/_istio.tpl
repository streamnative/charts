{{/*
Define the Istio Ingress Gateway Root Namespace
*/}}
{{- define "istio.namespace" -}}
{{- default "istio-system" .Values.istio.gateway.tls.cert_namespace -}}
{{- end -}}

{{/*
Define the Istio Ingress Gateway TLS cert Secret name
*/}}
{{- define "istio.credentialName" -}}
{{- if .Values.istio.gateway.tls.certSecretName -}}
{{- print .Values.istio.gateway.tls.certSecretName -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Values.istio.gateway.tls.cert_name -}}
{{- end -}}
{{- end -}}