
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
