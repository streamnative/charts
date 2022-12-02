{{/*
Define the streamnative-console service
*/}}
{{- define "pulsar.streamnative_console.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.streamnative_console.component }}
{{- end }}

{{/*
Define the streamnative-console hostname
*/}}
{{- define "pulsar.streamnative_console.hostname" -}}
${HOSTNAME}.{{ template "pulsar.streamnative_console.service" . }}.{{ template "pulsar.namespace" . }}.svc.cluster.local
{{- end -}}


{{/*
Define streamnative_console token mounts
*/}}
{{- define "pulsar.streamnative_console.token.volumeMounts" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
{{- if not .Values.auth.vault.enabled }}
- mountPath: "/pulsar/keys"
  name: token-keys
  readOnly: true
{{- end }}
- mountPath: "/pulsar/tokens"
  name: streamnative-console-token
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define streamnative-console token volumes
*/}}
{{- define "pulsar.streamnative_console.token.volumes" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
{{- if not .Values.auth.vault.enabled }}
- name: token-keys
  secret:
    {{- if not .Values.auth.authentication.jwt.usingSecretKey }}
    secretName: "{{ .Release.Name }}-token-asymmetric-key"
    {{- end}}
    {{- if .Values.auth.authentication.jwt.usingSecretKey }}
    secretName: "{{ .Release.Name }}-token-symmetric-key"
    {{- end}}
    items:
      {{- if .Values.auth.authentication.jwt.usingSecretKey }}
      - key: SECRETKEY
        path: token/secret.key
      {{- else }}
      - key: PUBLICKEY
        path: token/public.key
      - key: PRIVATEKEY
        path: token/private.key
      {{- end}}
{{- end }}
- name: streamnative-console-token
  secret:
    secretName: "{{ .Release.Name }}-token-{{ .Values.auth.superUsers.streamnative_console }}"
    items:
      - key: TOKEN
        path: streamnative_console/token
{{- end }}
{{- end }}
{{- if .Values.streamnative_console.force_vault }}
- name: streamnative-console-token
  secret:
    secretName: "{{ .Release.Name }}-token-{{ .Values.auth.superUsers.streamnative_console }}"
    items:
      - key: TOKEN
        path: streamnative_console/token
{{- end }}
{{- end }}

{{- define "pulsar.streamnative_console.data.pvc.name" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.streamnative_console.component }}-{{ .Values.streamnative_console.volumes.data.name }}
{{- end }}

{{- define "pulsar.streamnative_console.data.storage.class" -}}
{{- if  .Values.streamnative_console.volumes.data.storageClass }}
storageClassName: "{{ template "pulsar.streamnative_console.data.pvc.name" . }}"
{{- else if .Values.streamnative_console.volumes.data.storageClassName }}
storageClassName: "{{ .Values.streamnative_console.volumes.data.storageClassName }}"
{{- end }}
{{- end }}

{{/*Define service account*/}}
{{- define "pulsar.streamnative_console.serviceAccount" -}}
{{- if .Values.streamnative_console.serviceAccount.create -}}
    {{- if .Values.streamnative_console.serviceAccount.name -}}
{{ .Values.streamnative_console.serviceAccount.name }}
    {{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.streamnative_console.component }}-acct
    {{- end -}}
{{- else -}}
{{ .Values.streamnative_console.serviceAccount.name }}
{{- end -}}
{{- end -}}
