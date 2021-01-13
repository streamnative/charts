{{/*
Define the pulsar state storage service
*/}}
{{- define "pulsar.state_storage.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.state_storage.component }}
{{- end }}

{{- define "pulsar.state_storage.data.pvc.name" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.state_storage.component }}-{{ .Values.state_storage.volumes.data.name }}
{{- end }}

{{- define "pulsar.state_storage.data.storage.class" -}}
{{- if and .Values.volumes.local_storage .Values.state_storage.volumes.data.local_storage }}
storageClassName: "local-storage"
{{- else }}
  {{- if  .Values.state_storage.volumes.data.storageClass }}
storageClassName: "{{ template "pulsar.state_storage.data.pvc.name" . }}"
  {{- else if .Values.state_storage.volumes.data.storageClassName }}
storageClassName: "{{ .Values.state_storage.volumes.data.storageClassName }}"
  {{- end -}}
{{- end }}
{{- end }}

{{/*
Define state_storage log mounts
*/}}
{{- define "pulsar.state_storage.log.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.state_storage.component }}-log4j2"
  mountPath: "{{ template "pulsar.home" .}}/conf/log4j2.yaml"
  subPath: log4j2.yaml
{{- end }}

{{/*
Define state_storage log volumes
*/}}
{{- define "pulsar.state_storage.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.state_storage.component }}-log4j2"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.state_storage.component }}"
{{- end }}

{{/*Define state_storage service account*/}}
{{- define "pulsar.state_storage.serviceAccount" -}}
{{- if .Values.state_storage.serviceAccount.create -}}
    {{- if .Values.state_storage.serviceAccount.name -}}
{{ .Values.state_storage.serviceAccount.name }}
    {{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.state_storage.component }}-acct
    {{- end -}}
{{- else -}}
{{ .Values.state_storage.serviceAccount.name }}
{{- end -}}
{{- end -}}
