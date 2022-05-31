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

{{- define "pulsar.detector.broker-secret-key-name" -}}
{{- if .Values.pulsar_detector.broker.clientSecretName -}}
{{ .Values.pulsar_detector.broker.clientSecretName }}
{{- else -}}
{{ template "pulsar.fullname" . }}-vault-secret-env-injection
{{- end }}
{{- end }}

{{- define "pulsar.detector.clusterName" -}}
{{- if .Values.pulsar_detector.clusterName -}}
{{ .Values.pulsar_detector.clusterName }}
{{- else -}}
{{ template "pulsar.fullname" . }}
{{- end -}}
{{- end -}}
