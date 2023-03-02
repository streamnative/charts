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

{{/* Allow kubernetes version to be overridend */}}
{{- define "pulsar.kubeVersion" -}}
    {{- default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride -}}
{{- end -}}

{{/* Check Kubernetes version is less than v1.22 */}}
{{- define "pulsar.kubeVersion.isLessThanV122" -}}
    {{- if semverCompare "< 1.22-0" (include "pulsar.kubeVersion" .) -}}
        {{- print "true" -}}
    {{- else -}}
        {{- print "false" -}}
    {{- end -}}
{{- end -}}


{{/* Check Ingress API version is stable or not */}}
{{- define "pulsar.ingress.isStable" -}}
    {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" (include "pulsar.kubeVersion" .)) -}}
        {{- print "true" -}}
    {{- else -}}
        {{- print "false" -}}
    {{- end -}}
{{- end -}}


{{/* 
Get ingress image according to the k8s version.

When k8s version is higher or equal than v1.22, ingress image should use version v1.x.x,
otherwise it should use the default version 0.26.2 that defines in values.yaml.

If k8s version is higher or equal than v1.22, but the .Values.images.nginx_ingress_controller.tag is less than v1.x.x,
it will use registry.k8s.io/ingress-nginx/controller:v1.1.1 as default to make ingress work.
*/}}
{{- define "pulsar.ingress.image" -}}
    {{- if and (eq (include "pulsar.kubeVersion.isLessThanV122" .) "false") (semverCompare "< 1.0.0" .Values.images.nginx_ingress_controller.tag )}}
        {{- print "registry.k8s.io/ingress-nginx/controller:v1.1.1"}}
    {{- else -}}
        {{- printf "%s:%s" .Values.images.nginx_ingress_controller.repository .Values.images.nginx_ingress_controller.tag -}}
    {{- end -}}
{{- end -}}
