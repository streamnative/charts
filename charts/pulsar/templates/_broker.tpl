{{/*
Define the pulsar brroker service
*/}}
{{- define "pulsar.broker.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}
{{- end }}

{{/*
Define the hostname
*/}}
{{- define "pulsar.broker.hostname" -}}
${HOSTNAME}.{{ template "pulsar.broker.service" . }}.{{ .Values.namespace }}.svc.cluster.local
{{- end -}}

{{/*
Define the broker znode
*/}}
{{- define "pulsar.broker.znode" -}}
{{ .Values.metadataPrefix }}/loadbalance/brokers/{{ template "pulsar.broker.hostname" . }}:{{ .Values.broker.ports.http }}
{{- end }}

{{/*
Define broker zookeeper client tls settings
*/}}
{{- define "pulsar.broker.zookeeper.tls.settings" -}}
{{- if .Values.tls.zookeeper.enabled -}}
PASSWORD=$(head /dev/urandom | base64 | head -c 24);
openssl pkcs12 \
    -export \
    -in /pulsar/certs/broker/tls.crt \
    -inkey /pulsar/certs/broker/tls.key \
    -out /pulsar/broker.p12 \
    -name {{ template "pulsar.broker.hostname" . }} \
    -passout "pass:${PASSWORD}";
keytool -importkeystore \
    -srckeystore /pulsar/broker.p12 \
    -srcstoretype PKCS12 -srcstorepass "${PASSWORD}" \
    -alias {{ template "pulsar.broker.hostname" . }}  \
    -destkeystore /pulsar/broker.keystore.jks \
    -deststorepass "${PASSWORD}";
keytool -import \
    -file /pulsar/certs/ca/ca.crt \
    -storetype JKS \
    -alias {{ template "pulsar.broker.hostname" . }}  \
    -keystore /pulsar/broker.truststore.jks \
    -storepass "${PASSWORD}" \
    -trustcacerts -noprompt;
export PULSAR_EXTRA_OPTS="${PULSAR_EXTRA_OPTS} -Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty -Dzookeeper.client.secure=true -Dzookeeper.ssl.keyStore.location=/pulsar/broker.keystore.jks -Dzookeeper.ssl.keyStore.password=${PASSWORD} -Dzookeeper.ssl.trustStore.location=/pulsar/broker.truststore.jks -Dzookeeper.ssl.trustStore.password=${PASSWORD}";
export BOOKIE_EXTRA_OPTS="${PULSAR_EXTRA_OPTS}";
{{- end -}}
{{- end }}

{{/*
Define broker tls certs mounts
*/}}
{{- define "pulsar.broker.certs.volumeMounts" -}}
{{- if or .Values.tls.broker.enabled (or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled) -}}
- name: broker-certs
  mountPath: "/pulsar/certs/broker"
  readOnly: true
- name: ca
  mountPath: "/pulsar/certs/ca"
  readOnly: true
{{- end }}
{{- end }}

{{/*
Define broker tls certs volumes
*/}}
{{- define "pulsar.broker.certs.volumes" -}}
{{- if or .Values.tls.broker.enabled (or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled) -}}
- name: broker-certs
  secret:
    secretName: "{{ template "pulsar.fullname" . }}-{{ .Values.tls.broker.cert_name }}"
    items:
    - key: tls.crt
      path: tls.crt
    - key: tls.key
      path: tls.key
- name: ca
  secret:
    secretName: "{{ template "pulsar.fullname" . }}-ca-tls"
    items:
    - key: ca.crt
      path: ca.crt
{{- end -}}
{{- end }}