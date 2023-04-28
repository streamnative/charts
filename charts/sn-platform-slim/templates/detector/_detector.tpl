
{{/*Define pulsar detector service account*/}}
{{- define "pulsar.detector.serviceAccount" -}}
{{- if .Values.pulsar_detector.serviceAccount.create -}}
    {{- if .Values.pulsar_detector.serviceAccount.name -}}
{{ .Values.pulsar_detector.serviceAccount.name }}
    {{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.pulsar_detector.component }}-acct
    {{- end -}}
{{- else -}}
{{ .Values.pulsar_detector.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*Define pulsar detector service url, the TCP port*/}}
{{- define "pulsar.detector.serviceUrl" -}}
{{- if .Values.pulsar_detector.serviceUrl -}}
{{ .Values.pulsar_detector.serviceUrl -}}
{{- else -}}
{{ template "pulsar.broker.service.url" . }}
{{- end -}}
{{- end -}}

{{/*Define pulsar detector webservice url, the admin API*/}}
{{- define "pulsar.detector.webServiceUrl" -}}
{{- if .Values.pulsar_detector.webServiceUrl -}}
{{ .Values.pulsar_detector.webServiceUrl -}}
{{- else -}}
{{ template "pulsar.web.internal.service.url" . }}
{{- end -}}
{{- end -}}
