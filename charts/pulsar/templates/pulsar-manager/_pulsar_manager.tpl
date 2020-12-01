{{/*
Define pulsar_manager tls certs mounts
*/}}
{{- define "pulsar.pulsar_manager.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled (or .Values.tls.pulsar_manager.enabled .Values.tls.broker.enabled) }}
- name: pulsar-manager-certs
  mountPath: "/pulsar/certs/pulsar_manager"
  readOnly: true
- name: ca
  mountPath: "/pulsar/certs/ca"
  readOnly: true
- name: keytool
  mountPath: "/pulsar/keytool/keytool.sh"
  subPath: keytool.sh
{{- end }}
{{- end }}

{{/*
Define pulsar_manager tls certs volumes
*/}}
{{- define "pulsar.pulsar_manager.certs.volumes" -}}
{{- if and .Values.tls.enabled (or .Values.tls.pulsar_manager.enabled .Values.tls.broker.enabled) }}
- name: pulsar-manager-certs
  secret:
    secretName: "{{ .Release.Name }}-{{ .Values.tls.pulsar_manager.cert_name }}"
    items:
    - key: tls.crt
      path: tls.crt
    - key: tls.key
      path: tls.key
- name: ca
  secret:
    secretName: "{{ .Release.Name }}-ca-tls"
    items:
    - key: ca.crt
      path: ca.crt
- name: keytool
  configMap:
    name: "{{ template "pulsar.fullname" . }}-keytool-configmap"
    defaultMode: 0755
{{- end }}
{{- end }}

{{/*
Define the pulsar-manager service
*/}}
{{- define "pulsar.pulsar_manager.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.pulsar_manager.component }}
{{- end }}

{{/*
Define the pulsar-manager hostname
*/}}
{{- define "pulsar.pulsar_manager.hostname" -}}
${HOSTNAME}.{{ template "pulsar.pulsar_manager.service" . }}.{{ template "pulsar.namespace" . }}.svc.cluster.local
{{- end -}}



{{/*
Define pulsar-manager tls settings
*/}}
{{- define "pulsar.pulsar_manager.tls.settings" -}}
{{- if and .Values.tls.enabled .Values.tls.pulsar_manager.enabled }}
apk add --update openssl && rm -rf /var/cache/apk/*;
sh /pulsar/keytool/keytool.sh pulsar_manager {{ template "pulsar.pulsar_manager.hostname" . }} false;
{{- end }}
{{- end }}

{{/*
Define pulsar_manager token mounts
*/}}
{{- define "pulsar.pulsar_manager.token.volumeMounts" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
{{- if not .Values.auth.vault.enabled }}
- mountPath: "/pulsar/keys"
  name: token-keys
  readOnly: true
{{- end }}
- mountPath: "/pulsar/tokens"
  name: pulsar-manager-token
  readOnly: true
{{- end }}
{{- end }}
{{- if .Values.pulsar_manager.force_vault }}
- mountPath: "/pulsar/tokens"
  name: pulsar-manager-token
  readOnly: true
{{- end }}
{{- end }}

{{/*
Define pulsar-manager token volumes
*/}}
{{- define "pulsar.pulsar_manager.token.volumes" -}}
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
- name: pulsar-manager-token
  secret:
    secretName: "{{ .Release.Name }}-token-{{ .Values.auth.superUsers.pulsar_manager }}"
    items:
      - key: TOKEN
        path: pulsar_manager/token
{{- end }}
{{- end }}
{{- if .Values.pulsar_manager.force_vault }}
- name: pulsar-manager-token
  secret:
    secretName: "{{ .Release.Name }}-token-{{ .Values.auth.superUsers.pulsar_manager }}"
    items:
      - key: TOKEN
        path: pulsar_manager/token
{{- end }}
{{- end }}

