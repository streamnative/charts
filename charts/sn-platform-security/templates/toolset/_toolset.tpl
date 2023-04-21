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
Define toolset zookeeper client tls settings
*/}}
{{- define "pulsar.toolset.zookeeper.tls.settings" -}}
{{- if and .Values.tls.enabled (or .Values.tls.zookeeper.enabled (and .Values.tls.broker.enabled .Values.broker.kop.enabled)) }}
/pulsar/keytool/keytool.sh toolset {{ template "pulsar.toolset.hostname" . }} true;
{{- end -}}
{{- end }}

{{/*
Define toolset kafka settings
*/}}
{{- define "pulsar.toolset.kafka.settings" -}}
{{- if and .Values.tls.enabled (and .Values.tls.broker.enabled .Values.broker.kop.enabled) }}
cp conf/kafka.properties.template conf/kafka.properties;
echo "ssl.truststore.password=$(cat conf/password)" >> conf/kafka.properties;
{{- if and .Values.auth.authentication.enabled (eq .Values.auth.authentication.provider "jwt") }}
echo "sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \\" >> conf/kafka.properties;
echo '  username="public/default" \' >> conf/kafka.properties;
echo "  password=\"token:$(cat /pulsar/tokens/client/token)\";" >> conf/kafka.properties;
{{- end -}}
{{- end -}}
{{- end }}

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
Define toolset tls certs mounts
*/}}
{{- define "pulsar.toolset.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled (or .Values.tls.zookeeper.enabled .Values.tls.broker.enabled) }}
- name: toolset-certs
  mountPath: "/pulsar/certs/toolset"
  readOnly: true
- name: ca
  mountPath: "/pulsar/certs/ca"
  readOnly: true
{{- if or .Values.tls.zookeeper.enabled (and .Values.tls.broker.enabled .Values.toolset.kafka.enabled) }}
- name: keytool
  mountPath: "/pulsar/keytool/keytool.sh"
  subPath: keytool.sh
{{- end }}
{{- end }}
{{- if and .Values.toolset.useProxy .Values.tls.enabled (or .Values.tls.broker.enabled .Values.tls.proxy.enabled) }}
{{- if .Values.tls.proxy.untrustedCa }}
- mountPath: "/pulsar/certs/proxy-ca"
  name: proxy-ca
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define toolset tls certs volumes
*/}}
{{- define "pulsar.toolset.certs.volumes" -}}
{{- if and .Values.tls.enabled (or .Values.tls.zookeeper.enabled .Values.tls.broker.enabled) }}
- name: toolset-certs
  secret:
    secretName: "{{ template "pulsar.toolset.tls.secret.name" . }}"
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
{{- if or .Values.tls.zookeeper.enabled (and .Values.tls.broker.enabled .Values.toolset.kafka.enabled) }}
- name: keytool
  configMap:
    name: "{{ template "pulsar.fullname" . }}-keytool-configmap"
    defaultMode: 0755
{{- end }}
{{- end }}
{{- if and .Values.tls.enabled (or .Values.tls.broker.enabled .Values.tls.proxy.enabled) }}
{{- if .Values.tls.proxy.untrustedCa }}
- name: proxy-ca
  secret:
  {{- if and .Values.certs.public_issuer.enabled (eq .Values.certs.public_issuer.type "acme") }}
    secretName: {{ .Values.certs.lets_encrypt.ca_ref.secretName }}
    items:
      - key: {{ .Values.certs.lets_encrypt.ca_ref.keyName }}
        path: ca.crt
  {{- else }}
    secretName: "{{ template "pulsar.tls.ca.secret.name" . }}"
    items:
      - key: ca.crt
        path: ca.crt
  {{- end }}
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
Define toolset kafka conf mounts
*/}}
{{- define "pulsar.toolset.kafka.conf.volumeMounts" -}}
{{- if and .Values.tls.broker.enabled .Values.toolset.kafka.enabled }}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}-kafka-conf"
  mountPath: "{{ template "pulsar.home" . }}/conf/kafka.properties.template"
  subPath: kafka.properties
{{- end }}
{{- end }}

{{/*
Define toolset log volumes
*/}}
{{- define "pulsar.toolset.kafka.conf.volumes" -}}
{{- if and .Values.tls.broker.enabled .Values.toolset.kafka.enabled }}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}-kafka-conf"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}"
{{- end }}
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
Define toolset TLS certificate secret name
*/}}
{{- define "pulsar.toolset.tls.secret.name" -}}
{{- if .Values.tls.toolset.certSecretName -}}
{{- .Values.tls.toolset.certSecretName -}}
{{- else -}}
{{ .Release.Name }}-{{ .Values.tls.toolset.cert_name }}
{{- end -}}
{{- end -}}

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
  mountPath: "{{ template "pulsar.home" . }}/conf/pulsarctl.config"
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