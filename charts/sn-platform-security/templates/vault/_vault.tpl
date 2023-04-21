{{/*Define vault service account*/}}
{{- define "pulsar.vault.serviceAccount" -}}
{{- if .Values.vault.serviceAccount.created -}}
    {{- if .Values.vault.serviceAccount.name -}}
{{ .Values.vault.serviceAccount.name }}
    {{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-acct
    {{- end -}}
{{- else -}}
{{ .Values.vault.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Inject vault token values to pod through env variables
*/}}
{{- define "pulsar.vault-secret-key-name" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-secret-env-injection
{{- end }}

{{- define "pulsar.console-secret-key-name" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-console-admin-passwd
{{- end }}

{{/*Define vault datadog annotation*/}}
{{- define "pulsar.vault.datadog.annotation" -}}
{{- if .Values.datadog.components.vault.enabled }}
ad.datadoghq.com/vault.check_names: |
  ["vault"]
ad.datadoghq.com/vault.init_configs: |
  [{}]
ad.datadoghq.com/vault.instances: |
  [
    {
      "api_url": "http://%%host%%:8200/v1",
      {{- if .Values.datadog.components.vault.auth.enabled }}
      "client_token": {{ .Values.datadog.components.vault.auth.token }}
      {{- else }}
      "no_token": true
      {{- end }}
      {{- if .Values.datadog.components.vault.tags }}
      "tags": [
{{ toYaml .Values.datadog.components.vault.tags | indent 8 }}
       ]
       {{- end }}
    }
  ]
{{- end }}
{{- end }}

{{- define "pulsar.vault-unseal-secret-key-name" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-unseal-keys
{{- end }}


{{- define "pulsar.vault.url" -}}
http://{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}:8200
{{- end }}


{{- define "pulsar.vault.storage.class" -}}
{{- if .Values.vault.volume.storageClassName }}
storageClassName: "{{ .Values.vault.volume.storageClassName }}"
{{- end }}
{{- end }}

{{/*
Define pulsar vault root tokens volume mounts
*/}}
{{- define "pulsar.vault.rootToken.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-root-token"
  mountPath: "/vault/{{ template "pulsar.home" .}}/rootToken"
  subPath: vault-root
{{- end }}

{{/*
Define pulsar vault root tokens volume
*/}}
{{- define "pulsar.vault.rootToken.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-root-token"
  secret:
    secretName: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-unseal-keys"
{{- end }}

{{/*
Define pulsar create pulsar tokens volume mounts
*/}}
{{- define "pulsar.vault.createPulsarTokens.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-create-pulsar-tokens"
  mountPath: "/vault/{{ template "pulsar.home" .}}/create_pulsar_tokens/"
{{- end }}

{{/*
Define pulsar create pulsar tokens volumes
*/}}
{{- define "pulsar.vault.createPulsarTokens.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-create-pulsar-tokens"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-create-pulsar-tokens"
{{- end }}


{{/*
Define pulsar init pulsar manager volume mounts
*/}}
{{- define "pulsar.vault.initStreamNativeConsole.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-init-streamnative-console"
  mountPath: "/vault/{{ template "pulsar.home" .}}/init_vault_streamnative_console/"
{{- end }}

{{/*
Define pulsar init pulsar manager volumes
*/}}
{{- define "pulsar.vault.initStreamNativeConsole.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-init-streamnative-console"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-init-streamnative-console"
{{- end }}
