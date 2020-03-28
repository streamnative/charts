{{/*
Define the pulsar zookeeper
*/}}
{{- define "pulsar.zookeeper.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}
{{- end }}

{{/*
Define the pulsar zookeeper
*/}}
{{- define "pulsar.zookeeper.connect" -}}
{{- if not .Values.tls.zookeeper.enabled -}}
{{ template "pulsar.zookeeper.service" . }}:{{ .Values.zookeeper.ports.client }}
{{- end -}}
{{- if .Values.tls.zookeeper.enabled -}}
{{ template "pulsar.zookeeper.service" . }}:{{ .Values.zookeeper.ports.clientTls }}
{{- end -}}
{{- end -}}

{{/*
Define the zookeeper hostname
*/}}
{{- define "pulsar.zookeeper.hostname" -}}
${HOSTNAME}.{{ template "pulsar.zookeeper.service" . }}.{{ .Values.namespace }}.svc.cluster.local
{{- end -}}



{{/*
Define zookeeper tls settings
*/}}
{{- define "pulsar.zookeeper.tls.settings" -}}
{{- if .Values.tls.zookeeper.enabled }}
PASSWORD=$(head /dev/urandom | base64 | head -c 24);
openssl pkcs12 \
    -export \
    -in /pulsar/certs/zookeeper/tls.crt \
    -inkey /pulsar/certs/zookeeper/tls.key \
    -out /pulsar/zookeeper.p12 \
    -name {{ template "pulsar.zookeeper.hostname" . }} \
    -passout "pass:${PASSWORD}";
keytool -importkeystore \
    -srckeystore /pulsar/zookeeper.p12 \
    -srcstoretype PKCS12 -srcstorepass "${PASSWORD}" \
    -alias {{ template "pulsar.zookeeper.hostname" . }}  \
    -destkeystore /pulsar/zookeeper.keystore.jks \
    -deststorepass "${PASSWORD}";
keytool -import \
    -file /pulsar/certs/ca/ca.crt \
    -storetype JKS \
    -alias {{ template "pulsar.zookeeper.hostname" . }}  \
    -keystore /pulsar/zookeeper.truststore.jks \
    -storepass "${PASSWORD}" \
    -trustcacerts -noprompt;
export PULSAR_EXTRA_OPTS="${PULSAR_EXTRA_OPTS} -Dzookeeper.ssl.keyStore.location=/pulsar/zookeeper.keystore.jks -Dzookeeper.ssl.keyStore.password=${PASSWORD} -Dzookeeper.ssl.trustStore.location=/pulsar/zookeeper.truststore.jks -Dzookeeper.ssl.trustStore.password=${PASSWORD}";
{{- end }}
{{- end }}
