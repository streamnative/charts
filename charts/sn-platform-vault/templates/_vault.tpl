{{/*Define vault service account*/}}
{{- define "vault.serviceAccount" -}}
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

{{- define "vault.secetPrefix" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "console-secret-key-name" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-console-admin-passwd
{{- end }}

{{/*Define vault datadog annotation*/}}
{{- define "vault.datadog.annotation" -}}
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

{{- define "vault-unseal-secret-key-name" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-unseal-keys
{{- end }}

{{- define "vault.url" -}}
http://{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}:8200
{{- end }}

{{- define "vault.storage.class" -}}
{{- if and .Values.volumes.local_storage .Values.vault.volume.local_storage }}
storageClassName: "local-storage"
{{- else }}
  {{- if  .Values.vault.volume.storageClassName }}
storageClassName: "{{ .Values.vault.volume.storageClassName }}"
  {{- end -}}
{{- end }}
{{- end }}

{{/*
Define pulsar vault root tokens volume mounts
*/}}
{{- define "vault.rootToken.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-root-token"
  mountPath: "/root/{{ template "pulsar.home" .}}/rootToken"
  subPath: vault-root
{{- end }}

{{/*
Define pulsar vault root tokens volume
*/}}
{{- define "vault.rootToken.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-root-token"
  secret:
    secretName: "{{ template "vault-unseal-secret-key-name" }}
{{- end }}

{{/*
Define pulsar create pulsar tokens volume mounts
*/}}
{{- define "vault.createPulsarTokens.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-create-pulsar-tokens"
  mountPath: "/root/{{ template "pulsar.home" .}}/create_pulsar_tokens/"
{{- end }}

{{/*
Define pulsar create pulsar tokens volumes
*/}}
{{- define "vault.createPulsarTokens.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-create-pulsar-tokens"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-create-pulsar-tokens"
{{- end }}


{{/*
Define pulsar init pulsar manager volume mounts
*/}}
{{- define "vault.initStreamNativeConsole.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-init-streamnative-console"
  mountPath: "/root/{{ template "pulsar.home" .}}/init_vault_streamnative_console/"
{{- end }}

{{/*
Define pulsar init pulsar manager volumes
*/}}
{{- define "vault.initStreamNativeConsole.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-init-streamnative-console"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.vault.component }}-init-streamnative-console"
{{- end }}
