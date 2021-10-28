{{/*
Define the streamnative-console service
*/}}
{{- define "streamnative_console.service" -}}
{{ template "sn_console.fullname" . }}-{{ .Values.component }}
{{- end }}

{{/*
Define the streamnative-console backend service
*/}}
{{- define "streamnative_console.backend.service" -}}
{{ template "sn_console.fullname" . }}-{{ .Values.component }}-backend
{{- end }}

{{/*
Define the streamnative-console hostname
*/}}
{{- define "streamnative_console.hostname" -}}
${HOSTNAME}.{{ template "streamnative_console.service" . }}.{{ template "sn_console.namespace" . }}.svc.cluster.local
{{- end -}}

{{/*
Define streamnative_console token mounts
*/}}
{{- define "streamnative_console.token.volumeMounts" -}}
{{- if .Values.broker.auth.authentication.enabled }}
{{- if eq .Values.broker.auth.authentication.provider "jwt" }}
{{- if not .Values.broker.auth.vault.enabled }}
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
{{- define "streamnative_console.token.volumes" -}}
{{- if .Values.broker.auth.authentication.enabled }}
{{- if eq .Values.broker.auth.authentication.provider "jwt" }}
{{- if not .Values.broker.auth.vault.enabled }}
- name: token-keys
  secret:
    secretName: "{{ .Values.broker.auth.authentication.jwt.tokenKeySecretRef }}"
    items:
      {{- if .Values.broker.auth.authentication.jwt.usingSecretKey }}
      - key: SECRETKEY
        path: token/secret.key
      {{- else }}
      - key: PUBLICKEY
        path: token/public.key
      - key: PRIVATEKEY
        path: token/private.key
      {{- end}}
- name: streamnative-console-token
  secret:
    secretName: "{{ .Values.broker.auth.jwt.superUserSecretRef }}"
    items:
      - key: TOKEN
        path: streamnative_console/token
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "streamnative_console.data.pvc.name" -}}
{{ template "sn_console.fullname" . }}-streamnative-console-{{ .Values.volumes.data.name }}
{{- end }}

{{- define "streamnative_console.data.storage.class" -}}
{{- if .Values.volumes.data.local_storage }}
storageClassName: "local-storage"
{{- else }}
  {{- if  .Values.volumes.data.storageClass }}
storageClassName: "{{ template "streamnative_console.data.pvc.name" . }}"
  {{- else if .Values.volumes.data.storageClassName }}
storageClassName: "{{ .Values.volumes.data.storageClassName }}"
  {{- end -}}
{{- end }}
{{- end }}

{{/*
Inject vault token values to pod through env variables
*/}}
{{- define "streamnative_console.vault-secret-key-name" -}}
{{- if .Values.broker.auth.authentication.vault.secretKeyRef -}}
{{ .Values.broker.auth.authentication.vault.secretKeyRef }}
{{- else -}}
{{ template "sn_console.fullname" . }}-vault-secret-env-injection
{{- end -}}
{{- end -}}

{{- define "streamnative_console.admin-passwd-secret" -}}
{{- if .Values.broker.auth.authentication.vault.adminPasswordSecretRef -}}
{{ .Values.broker.auth.authentication.vault.adminPasswordSecretRef }}
{{- else -}}
{{ template "sn_console.fullname" . }}-vault-console-admin-passwd
{{- end -}}
{{- end -}}
