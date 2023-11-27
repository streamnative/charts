{{/*
Define the pulsar toolset service
*/}}
{{- define "pulsar.toolset.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}
{{- end }}

{{/*
Define the toolset hostname
*/}}
{{- define "pulsar.toolset.hostname" -}}
${HOSTNAME}.{{ template "pulsar.toolset.service" . }}.{{ template "pulsar.namespace" . }}.svc.cluster.local
{{- end -}}

{{/*
Define toolset token mounts
*/}}
{{- define "pulsar.toolset.token.volumeMounts" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
- mountPath: "/pulsar/tokens"
  name: client-token
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define toolset token volumes
*/}}
{{- define "pulsar.toolset.token.volumes" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
- name: client-token
  secret:
    secretName: "{{ .Release.Name }}-token-{{ .Values.auth.superUsers.client }}"
    items:
      - key: TOKEN
        path: client/token
{{- end }}
{{- end }}
{{- end }}

{{/*
Define toolset log mounts
*/}}
{{- define "pulsar.toolset.log.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}-log4j2"
  mountPath: "{{ template "pulsar.home" . }}/conf/log4j2.yaml"
  subPath: log4j2.yaml
{{- end }}

{{/*
Define toolset log volumes
*/}}
{{- define "pulsar.toolset.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}-log4j2"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}"
{{- end }}

{{/*
pulsar toolset image
*/}}
{{- define "pulsar.toolset.image" -}}
{{- if .Values.images.toolset }}
image: "{{ .Values.images.toolset.repository }}:{{ .Values.images.toolset.tag }}"
imagePullPolicy: {{ .Values.images.toolset.pullPolicy }}
{{- else }}
image: "{{ .Values.images.broker.repository }}:{{ .Values.images.broker.tag }}"
imagePullPolicy: {{ .Values.images.broker.pullPolicy }}
{{- end }}
{{- end }}

{{/*
Define the toolset web service url
*/}}
{{- define "toolset.web.service.url" -}}
{{- if not .Values.toolset.useProxy -}}
{{- if and .Values.tls.enabled .Values.tls.broker.enabled -}}
https://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}:{{ .Values.broker.ports.https }}
{{- else -}}
http://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}:{{ .Values.broker.ports.http }}
{{- end -}}
{{- else -}}
{{- if and .Values.tls.enabled .Values.tls.proxy.enabled -}}
https://{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}:{{ .Values.proxy.ports.https }}
{{- else -}}
http://{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}:{{ .Values.proxy.ports.http }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Define pulsarctl config volume mount
*/}}
{{- define "pulsar.toolset.pulsarctl.conf.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}-pulsarctl"
  mountPath: "/home/pulsar/.config/pulsar/config"
  subPath: pulsarctl.config
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}-pulsarctl"
  mountPath: "/root/.config/pulsar/config"
  subPath: pulsarctl.config
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}-pulsarctl"
  mountPath: "/.config/pulsar/config"
  subPath: pulsarctl.config
{{- end }}
{{/*
Define toolset pulsarctl config volumes
*/}}
{{- define "pulsar.toolset.pulsarctl.conf.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}-pulsarctl"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}"
{{- end }}

{{/*Define service account*/}}
{{- define "pulsar.toolset.serviceAccount" -}}
{{- if .Values.toolset.serviceAccount.create -}}
    {{- if .Values.toolset.serviceAccount.name -}}
{{ .Values.toolset.serviceAccount.name }}
    {{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}-acct
    {{- end -}}
{{- else -}}
{{ .Values.toolset.serviceAccount.name }}
{{- end -}}
{{- end -}}