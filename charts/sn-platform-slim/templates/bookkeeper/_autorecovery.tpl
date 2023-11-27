{{/*
Define the pulsar autorecovery service
*/}}
{{- define "pulsar.autorecovery.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.autorecovery.component }}
{{- end }}

{{/*
Define the autorecovery hostname
*/}}
{{- define "pulsar.autorecovery.hostname" -}}
${HOSTNAME}.{{ template "pulsar.autorecovery.service" . }}.{{ template "pulsar.namespace" . }}.svc.cluster.local
{{- end -}}

{{/*
Define autorecovery log mounts
*/}}
{{- define "pulsar.autorecovery.log.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.autorecovery.component }}-log4j2"
  mountPath: "{{ template "pulsar.home" . }}/conf/log4j2.yaml"
  subPath: log4j2.yaml
{{- end }}

{{/*
Define autorecovery log volumes
*/}}
{{- define "pulsar.autorecovery.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.autorecovery.component }}-log4j2"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.autorecovery.component }}"
{{- end }}
