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
${HOSTNAME}.{{ template "pulsar.toolset.service" . }}.{{ .Values.namespace }}.svc.cluster.local
{{- end -}}

{{/*
Define toolset zookeeper client tls settings
*/}}
{{- define "pulsar.toolset.zookeeper.tls.settings" -}}
{{- if .Values.tls.zookeeper.enabled -}}
PASSWORD=$(head /dev/urandom | base64 | head -c 24);
openssl pkcs12 \
    -export \
    -in /pulsar/certs/toolset/tls.crt \
    -inkey /pulsar/certs/toolset/tls.key \
    -out /pulsar/toolset.p12 \
    -name {{ template "pulsar.toolset.hostname" . }} \
    -passout "pass:${PASSWORD}";
keytool -importkeystore \
    -srckeystore /pulsar/toolset.p12 \
    -srcstoretype PKCS12 -srcstorepass "${PASSWORD}" \
    -alias {{ template "pulsar.toolset.hostname" . }}  \
    -destkeystore /pulsar/toolset.keystore.jks \
    -deststorepass "${PASSWORD}";
keytool -import \
    -file /pulsar/certs/ca/ca.crt \
    -storetype JKS \
    -alias {{ template "pulsar.toolset.hostname" . }}  \
    -keystore /pulsar/toolset.truststore.jks \
    -storepass "${PASSWORD}" \
    -trustcacerts -noprompt;
echo "\nBOOKIE_EXTRA_OPTS=\"${BOOKIE_EXTRA_OPTS} -Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty -Dzookeeper.client.secure=true -Dzookeeper.ssl.keyStore.location=/pulsar/toolset.keystore.jks -Dzookeeper.ssl.keyStore.password=${PASSWORD} -Dzookeeper.ssl.trustStore.location=/pulsar/toolset.truststore.jks -Dzookeeper.ssl.trustStore.password=${PASSWORD}\"" >> {{ template "pulsar.home" . }}/conf/bkenv.sh;
echo "\nPULSAR_EXTRA_OPTS=\"${PULSAR_EXTRA_OPTS} -Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty -Dzookeeper.client.secure=true -Dzookeeper.ssl.keyStore.location=/pulsar/toolset.keystore.jks -Dzookeeper.ssl.keyStore.password=${PASSWORD} -Dzookeeper.ssl.trustStore.location=/pulsar/toolset.truststore.jks -Dzookeeper.ssl.trustStore.password=${PASSWORD}\"" >> {{ template "pulsar.home" . }}/conf/pulsar_env.sh;
{{- end -}}
{{- end }}

{{/*
Define toolset tls certs mounts
*/}}
{{- define "pulsar.toolset.certs.volumeMounts" -}}
{{- if .Values.tls.zookeeper.enabled }}
- name: toolset-certs
  mountPath: "/pulsar/certs/toolset"
  readOnly: true
- name: ca
  mountPath: "/pulsar/certs/ca"
  readOnly: true
{{- end }}
{{- end }}

{{/*
Define toolset tls certs volumes
*/}}
{{- define "pulsar.toolset.certs.volumes" -}}
{{- if .Values.tls.zookeeper.enabled -}}
- name: toolset-certs
  secret:
    secretName: "{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}"
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