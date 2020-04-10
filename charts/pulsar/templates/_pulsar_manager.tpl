{{/*
Define pulsar_manager tls certs mounts
*/}}
{{- define "pulsar.pulsar_manager.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled (or .Values.tls.pulsar_manager.enabled .Values.tls.broker.enabled) }}
- name: pulsar-manager-certs
  mountPath: "/pulsar/certs/pulsar_manager"
  readOnly: true
- name: ca
  mountPath: "/pulsar/certs/ca"
  readOnly: true
- name: keytool
  mountPath: "/pulsar/keytool/keytool.sh"
  subPath: keytool.sh
{{- end }}
{{- end }}

{{/*
Define pulsar_manager tls certs volumes
*/}}
{{- define "pulsar.pulsar_manager.certs.volumes" -}}
{{- if and .Values.tls.enabled (or .Values.tls.pulsar_manager.enabled .Values.tls.broker.enabled) }}
- name: pulsar-manager-certs
  secret:
    secretName: "{{ template "pulsar.fullname" . }}-{{ .Values.tls.pulsar_manager.cert_name }}"
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
- name: keytool
  configMap:
    name: "{{ template "pulsar.fullname" . }}-keytool-configmap"
    defaultMode: 0755
{{- end }}
{{- end }}

{{/*
Define the pulsar-manager service
*/}}
{{- define "pulsar.pulsar_manager.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.pulsar_manager.component }}
{{- end }}

{{/*
Define the pulsar-manager hostname
*/}}
{{- define "pulsar.pulsar_manager.hostname" -}}
${HOSTNAME}.{{ template "pulsar.pulsar_manager.service" . }}.{{ .Values.namespace }}.svc.cluster.local
{{- end -}}



{{/*
Define pulsar-manager tls settings
*/}}
{{- define "pulsar.pulsar_manager.tls.settings" -}}
{{- if and .Values.tls.enabled .Values.tls.pulsar_manager.enabled }}
apk add --update openssl && rm -rf /var/cache/apk/*;
sh /pulsar/keytool/keytool.sh pulsar_manager {{ template "pulsar.pulsar_manager.hostname" . }} false;
{{- end }}
{{- end }}

