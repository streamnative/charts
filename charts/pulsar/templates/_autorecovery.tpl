{{/*
Define the pulsar autorecovery service
*/}}
{{- define "pulsar.autorecovery.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.autorecovery.component }}
{{- end }}

{{/*
Define the autorecovery hostname
*/}}
{{- define "pulsar.autorecovery.hostname" -}}
${HOSTNAME}.{{ template "pulsar.autorecovery.service" . }}.{{ .Values.namespace }}.svc.cluster.local
{{- end -}}

{{/*
Define autorecovery zookeeper client tls settings
*/}}
{{- define "pulsar.autorecovery.zookeeper.tls.settings" -}}
{{- if .Values.tls.zookeeper.enabled -}}
PASSWORD=$(head /dev/urandom | base64 | head -c 24);
openssl pkcs12 \
    -export \
    -in /pulsar/certs/autorecovery/tls.crt \
    -inkey /pulsar/certs/autorecovery/tls.key \
    -out /pulsar/autorecovery.p12 \
    -name {{ template "pulsar.autorecovery.hostname" . }} \
    -passout "pass:${PASSWORD}";
keytool -importkeystore \
    -srckeystore /pulsar/autorecovery.p12 \
    -srcstoretype PKCS12 -srcstorepass "${PASSWORD}" \
    -alias {{ template "pulsar.autorecovery.hostname" . }}  \
    -destkeystore /pulsar/autorecovery.keystore.jks \
    -deststorepass "${PASSWORD}";
keytool -import \
    -file /pulsar/certs/ca/ca.crt \
    -storetype JKS \
    -alias {{ template "pulsar.autorecovery.hostname" . }}  \
    -keystore /pulsar/autorecovery.truststore.jks \
    -storepass "${PASSWORD}" \
    -trustcacerts -noprompt;
export BOOKIE_EXTRA_OPTS="${BOOKIE_EXTRA_OPTS} -Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty -Dzookeeper.client.secure=true -Dzookeeper.ssl.keyStore.location=/pulsar/autorecovery.keystore.jks -Dzookeeper.ssl.keyStore.password=${PASSWORD} -Dzookeeper.ssl.trustStore.location=/pulsar/autorecovery.truststore.jks -Dzookeeper.ssl.trustStore.password=${PASSWORD}";
{{- end -}}
{{- end }}

{{/*
Define autorecovery tls certs mounts
*/}}
{{- define "pulsar.autorecovery.certs.volumeMounts" -}}
{{- if .Values.tls.zookeeper.enabled }}
- name: autorecovery-certs
  mountPath: "/pulsar/certs/autorecovery"
  readOnly: true
- name: ca
  mountPath: "/pulsar/certs/ca"
  readOnly: true
{{- end }}
{{- end }}

{{/*
Define autorecovery tls certs volumes
*/}}
{{- define "pulsar.autorecovery.certs.volumes" -}}
{{- if .Values.tls.zookeeper.enabled -}}
- name: autorecovery-certs
  secret:
    secretName: "{{ template "pulsar.fullname" . }}-{{ .Values.autorecovery.component }}"
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

{{/*
Define autorecovery init container : verify cluster id
*/}}
{{- define "pulsar.autorecovery.init.verify_cluster_id" -}}
bin/apply-config-from-env.py conf/bookkeeper.conf;
{{- include "pulsar.autorecovery.zookeeper.tls.settings" . }}
until bin/bookkeeper shell whatisinstanceid; do
  sleep 3;
done;
{{- end }}