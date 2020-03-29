{{/*
Define the pulsar bookkeeper service
*/}}
{{- define "pulsar.bookkeeper.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.bookkeeper.component }}
{{- end }}

{{/*
Define the bookkeeper hostname
*/}}
{{- define "pulsar.bookkeeper.hostname" -}}
${HOSTNAME}.{{ template "pulsar.bookkeeper.service" . }}.{{ .Values.namespace }}.svc.cluster.local
{{- end -}}


{{/*
Define bookie zookeeper client tls settings
*/}}
{{- define "pulsar.bookkeeper.zookeeper.tls.settings" -}}
{{- if .Values.tls.zookeeper.enabled -}}
PASSWORD=$(head /dev/urandom | base64 | head -c 24);
openssl pkcs12 \
    -export \
    -in /pulsar/certs/bookie/tls.crt \
    -inkey /pulsar/certs/bookie/tls.key \
    -out /pulsar/bookie.p12 \
    -name {{ template "pulsar.bookkeeper.hostname" . }} \
    -passout "pass:${PASSWORD}";
keytool -importkeystore \
    -srckeystore /pulsar/bookie.p12 \
    -srcstoretype PKCS12 -srcstorepass "${PASSWORD}" \
    -alias {{ template "pulsar.bookkeeper.hostname" . }}  \
    -destkeystore /pulsar/bookie.keystore.jks \
    -deststorepass "${PASSWORD}";
keytool -import \
    -file /pulsar/certs/ca/ca.crt \
    -storetype JKS \
    -alias {{ template "pulsar.bookkeeper.hostname" . }}  \
    -keystore /pulsar/bookie.truststore.jks \
    -storepass "${PASSWORD}" \
    -trustcacerts -noprompt;
export PULSAR_EXTRA_OPTS="${PULSAR_EXTRA_OPTS} -Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty -Dzookeeper.client.secure=true -Dzookeeper.ssl.keyStore.location=/pulsar/bookie.keystore.jks -Dzookeeper.ssl.keyStore.password=${PASSWORD} -Dzookeeper.ssl.trustStore.location=/pulsar/bookie.truststore.jks -Dzookeeper.ssl.trustStore.password=${PASSWORD}";
{{- end -}}
{{- end }}

{{/*
Define bookie tls certs mounts
*/}}
{{- define "pulsar.bookkeeper.certs.volumeMounts" -}}
{{- if or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled }}
- name: bookie-certs
  mountPath: "/pulsar/certs/bookie"
  readOnly: true
- name: ca
  mountPath: "/pulsar/certs/ca"
  readOnly: true
{{- end }}
{{- end }}

{{/*
Define bookie tls certs volumes
*/}}
{{- define "pulsar.bookkeeper.certs.volumes" -}}
{{- if or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled -}}
- name: bookie-certs
  secret:
    secretName: "{{ template "pulsar.fullname" . }}-{{ .Values.tls.bookie.cert_name }}"
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
Define bookie common config
*/}}
{{- define "pulsar.bookkeeper.config.common" -}}
zkServers: "{{ template "pulsar.zookeeper.connect" . }}"
zkLedgersRootPath: "{{ .Values.metadataPrefix }}/ledgers"
# enable bookkeeper http server
httpServerEnabled: "true"
httpServerPort: "{{ .Values.bookkeeper.ports.http }}"
# config the stats provider
statsProviderClass: org.apache.bookkeeper.stats.prometheus.PrometheusMetricsProvider
# use hostname as the bookie id
useHostNameAsBookieID: "true"
{{- end }}

{{/*
Define bookie tls config
*/}}
{{- define "pulsar.bookkeeper.config.tls" -}}
{{- if and .Values.tls.enabled .Values.tls.bookie.enabled }}
PULSAR_PREFIX_tlsProviderFactoryClass: org.apache.bookkeeper.tls.TLSContextFactory
PULSAR_PREFIX_tlsCertificatePath: /pulsar/certs/bookie/tls.crt  
PULSAR_PREFIX_tlsKeyStoreType: PEM
PULSAR_PREFIX_tlsKeyStore: /pulsar/certs/bookie/tls.key
PULSAR_PREFIX_tlsTrustStoreType: PEM
PULSAR_PREFIX_tlsTrustStore: /pulsar/certs/ca/ca.crt 
{{- end }}
{{- end }}

{{/*
Define bookie init container : verify cluster id
*/}}
{{- define "pulsar.bookkeeper.init.verify_cluster_id" -}}
{{- if .Values.tls.zookeeper.enabled -}}
{{- if not (and .Values.volumes.persistence .Values.bookkeeper.volumes.persistence) }}
bin/apply-config-from-env.py conf/bookkeeper.conf;
{{- include "pulsar.bookkeeper.zookeeper.tls.settings" . }}
export BOOKIE_EXTRA_OPTS="${BOOKIE_EXTRA_OPTS} -Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty -Dzookeeper.client.secure=true -Dzookeeper.ssl.keyStore.location=/pulsar/bookie.keystore.jks -Dzookeeper.ssl.keyStore.password=${PASSWORD} -Dzookeeper.ssl.trustStore.location=/pulsar/bookie.truststore.jks -Dzookeeper.ssl.trustStore.password=${PASSWORD}";
until bin/bookkeeper shell whatisinstanceid; do
  sleep 3;
done;
bin/bookkeeper shell bookieformat -nonInteractive -force -deleteCookie || true
{{- end -}}
{{- if and .Values.volumes.persistence .Values.bookkeeper.volumes.persistence }}
set -e;
bin/apply-config-from-env.py conf/bookkeeper.conf;
{{- include "pulsar.bookkeeper.zookeeper.tls.settings" . }}
export BOOKIE_EXTRA_OPTS="${BOOKIE_EXTRA_OPTS} -Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty -Dzookeeper.client.secure=true -Dzookeeper.ssl.keyStore.location=/pulsar/bookie.keystore.jks -Dzookeeper.ssl.keyStore.password=${PASSWORD} -Dzookeeper.ssl.trustStore.location=/pulsar/bookie.truststore.jks -Dzookeeper.ssl.trustStore.password=${PASSWORD}";
until bin/bookkeeper shell whatisinstanceid; do
  sleep 3;
done;
{{- end -}}
{{- end -}}
{{- end }}