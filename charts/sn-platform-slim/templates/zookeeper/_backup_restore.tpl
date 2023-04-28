
{{- define "pulsar.zookeeper.backup.serviceAccount" -}}
{{- if .Values.zookeeper.customTools.serviceAccount.create -}}
{{- if .Values.zookeeper.customTools.serviceAccount.name -}}
{{ .Values.zookeeper.customTools.serviceAccount.name }}
{{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.customTools.backup.component }}-acct
{{- end -}}
{{- else -}}
{{ .Values.zookeeper.customTools.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "pulsar.zookeeper.restore.serviceAccount" -}}
{{- if .Values.zookeeper.customTools.serviceAccount.create -}}
{{- if .Values.zookeeper.customTools.serviceAccount.name -}}
{{ .Values.zookeeper.customTools.serviceAccount.name }}
{{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.customTools.restore.component }}-acct
{{- end -}}
{{- else -}}
{{ .Values.zookeeper.customTools.serviceAccount.name }}
{{- end -}}
{{- end -}}