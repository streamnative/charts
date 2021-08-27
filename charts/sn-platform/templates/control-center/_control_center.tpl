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