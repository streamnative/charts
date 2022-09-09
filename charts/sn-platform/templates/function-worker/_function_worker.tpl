{{/*Define function worker service account*/}}
{{- define "pulsar.function.serviceAccount" -}}
{{- if .Values.functions.serviceAccount.create -}}
    {{- if .Values.functions.serviceAccount.name -}}
{{ .Values.functions.serviceAccount.name }}
    {{- else -}}
{{ template "pulsar.fullname" . }}-{{ .Values.functions.component }}-acct
    {{- end -}}
{{- else -}}
{{ .Values.functions.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Pulsar Broker Service URL
*/}}
{{- define "pulsar.function.broker.service.url" -}}
{{- if or .Values.functions.useDedicatedRunner (eq .Values.functions.configData.functionRuntimeFactoryClassName "org.apache.pulsar.functions.runtime.kubernetes.KubernetesRuntimeFactory") -}}
pulsar://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}.{{ template "pulsar.namespace" . }}.svc.cluster.local:{{ .Values.proxy.ports.pulsar }}
{{- else -}}
pulsar://localhost:6650
{{- end -}}
{{- end -}}

{{/*
Pulsar Web Service URL
*/}}
{{- define "pulsar.function.web.service.url" -}}
{{- if or .Values.functions.useDedicatedRunner (eq .Values.functions.configData.functionRuntimeFactoryClassName "org.apache.pulsar.functions.runtime.kubernetes.KubernetesRuntimeFactory") -}}
http://{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.{{ template "pulsar.namespace" . }}.svc.cluster.local:{{ .Values.proxy.ports.http }}
{{- else -}}
http://localhost:8080
{{- end -}}
{{- end -}}

{{/*
Pulsar Broker Service URL TLS
*/}}
{{- define "pulsar.function.broker.service.url.tls" -}}
{{- if or .Values.functions.useDedicatedRunner (eq .Values.functions.configData.functionRuntimeFactoryClassName "org.apache.pulsar.functions.runtime.kubernetes.KubernetesRuntimeFactory") -}}
{{- if and .Values.components.proxy (not .Values.istio.enabled) -}}
pulsar+ssl://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}.{{ template "pulsar.namespace" . }}.svc.cluster.local:{{ .Values.proxy.ports.pulsarssl }}
{{- else -}}
pulsar+ssl://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}.{{ template "pulsar.namespace" . }}.svc.cluster.local:{{ .Values.broker.ports.pulsarssl }}
{{- end -}}
{{- else -}}
pulsar+ssl://localhost:6651
{{- end -}}
{{- end -}}

{{/*
Pulsar Web Service URL TLS
*/}}
{{- define "pulsar.function.web.service.url.tls" -}}
{{- if or .Values.functions.useDedicatedRunner (eq .Values.functions.configData.functionRuntimeFactoryClassName "org.apache.pulsar.functions.runtime.kubernetes.KubernetesRuntimeFactory") -}}
{{- if and .Values.components.proxy (not .Values.istio.enabled) -}}
https://{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}.{{ template "pulsar.namespace" . }}.svc.cluster.local:{{ .Values.proxy.ports.https }}
{{- else -}}
https://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}.{{ template "pulsar.namespace" . }}.svc.cluster.local:{{ .Values.broker.ports.https }}
{{- end -}}
{{- else -}}
https://localhost:8443
{{- end -}}
{{- end -}}

{{/*
Define function tls certs mounts
*/}}
{{- define "pulsar.function.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled .Values.tls.functions.enabled }}
- name: function-certs
  mountPath: "/pulsar/certs/function"
  readOnly: true
- name: ca
  mountPath: "/pulsar/certs/ca"
  readOnly: true
{{- end }}
{{- end }}

{{/*
Define function tls certs volumes
*/}}
{{- define "pulsar.function.certs.volumes" -}}
{{- if and .Values.tls.enabled .Values.tls.functions.enabled }}
- name: function-certs
  secret:
    secretName: "{{ template "pulsar.function.tls.secret.name" . }}"
    items:
    - key: tls.crt
      path: tls.crt
    - key: tls.key
      path: tls.key
- name: ca
  secret:
    secretName: "{{ template "pulsar.tls.ca.secret.name" . }}"
    items:
    - key: ca.crt
      path: ca.crt
{{- end }}
{{- end }}

{{/*
Define the pulsar function full service name
*/}}
{{- define "pulsar.function.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.functions.component }}
{{- end }}


{{/*
Define function token mounts
*/}}
{{- define "pulsar.function.token.volumeMounts" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
{{- if not .Values.auth.vault.enabled }}
- mountPath: "/pulsar/keys"
  name: token-keys
  readOnly: true
{{- end }}
- mountPath: "/pulsar/tokens"
  name: function-token
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define function token volumes
*/}}
{{- define "pulsar.function.token.volumes" -}}
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
      {{- end}}
{{- end }}
- name: function-token
  secret:
    secretName: "{{ .Release.Name }}-token-{{ .Values.auth.superUsers.broker }}"
    items:
      - key: TOKEN
        path: function/token
{{- end }}
{{- end }}
{{- end }}

{{/*
Define Function worker TLS certificate secret name
*/}}
{{- define "pulsar.function.tls.secret.name" -}}
{{- if .Values.tls.functions.certSecretName -}}
{{- .Values.tls.functions.certSecretName -}}
{{- else -}}
{{ .Release.Name }}-{{ .Values.tls.functions.cert_name }}
{{- end -}}
{{- end -}}
