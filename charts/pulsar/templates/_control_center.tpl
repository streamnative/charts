{{/*
control center domain
*/}}
{{- define "pulsar.control_center_domain" -}}
{{- if .Values.ingress.control_center.enabled -}}
    {{- if .Values.ingress.control_center.external_domain }}
{{- printf "%s" .Values.ingress.control_center.external_domain -}}
    {{- else -}}
{{- printf "admin.%s.%s" .Release.Name .Values.external_dns.domain_filter -}}
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
        {{- if .Values.ingress.controller.services.https.enabled }}
{{- printf "https://admin.%s.%s" .Release.Name .Values.external_dns.domain_filter -}}
        {{- else -}}
{{- printf "http://admin.%s.%s" .Release.Name .Values.external_dns.domain_filter -}}
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
{{- if .Values.ingress.control_center.enabled -}}
{{- print "/alerts" -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}

{{/*
control center path: grafana
*/}}
{{- define "pulsar.control_center_path.grafana" -}}
{{- if .Values.ingress.control_center.enabled -}}
{{- print "/grafana" -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}

{{/*
control center path: prometheus
*/}}
{{- define "pulsar.control_center_path.prometheus" -}}
{{- if .Values.ingress.control_center.enabled -}}
{{- print "/prometheus" -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}