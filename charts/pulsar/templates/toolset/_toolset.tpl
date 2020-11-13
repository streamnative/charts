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
{{- if and .Values.tls.enabled (or .Values.tls.zookeeper.enabled (and .Values.tls.broker.enabled .Values.components.kop)) }}
/pulsar/keytool/keytool.sh toolset {{ template "pulsar.toolset.hostname" . }} true;
{{- end -}}
{{- end }}

{{/*
Define toolset kafka settings
*/}}
{{- define "pulsar.toolset.kafka.settings" -}}
{{- if and .Values.tls.enabled (and .Values.tls.broker.enabled .Values.components.kop) }}
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
{{- if or .Values.tls.zookeeper.enabled (and .Values.tls.broker.enabled .Values.components.kop) }}
- name: keytool
  mountPath: "/pulsar/keytool/keytool.sh"
  subPath: keytool.sh
{{- end }}
{{- end }}
{{- if and .Values.tls.enabled (or .Values.tls.broker.enabled .Values.tls.proxy.enabled) }}
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
    secretName: "{{ .Release.Name }}-{{ .Values.tls.toolset.cert_name }}"
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
{{- if or .Values.tls.zookeeper.enabled (and .Values.tls.broker.enabled .Values.components.kop) }}
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
    secretName: "{{ .Release.Name }}-ca-tls"
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
{{- if and .Values.tls.broker.enabled .Values.components.kop }}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}-kafka-conf"
  mountPath: "{{ template "pulsar.home" . }}/conf/kafka.properties.template"
  subPath: kafka.properties
{{- end }}
{{- end }}

{{/*
Define toolset log volumes
*/}}
{{- define "pulsar.toolset.kafka.conf.volumes" -}}
{{- if and .Values.tls.broker.enabled .Values.components.kop }}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}-kafka-conf"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}"
{{- end }}
{{- end }}
