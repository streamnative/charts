{{/*
Define websocket token mounts
*/}}
{{- define "pulsar.websocket.token.volumeMounts" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
- mountPath: "/pulsar/keys"
  name: token-keys
  readOnly: true
- mountPath: "/pulsar/tokens"
  name: websocket-token
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define websocket token volumes
*/}}
{{- define "pulsar.websocket.token.volumes" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
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
      {{- end}}
- name: websocket-token
  secret:
    secretName: "{{ .Release.Name }}-token-{{ .Values.auth.superUsers.websocket }}"
    items:
      - key: TOKEN
        path: websocket/token
{{- end }}
{{- end }}
{{- end }}
