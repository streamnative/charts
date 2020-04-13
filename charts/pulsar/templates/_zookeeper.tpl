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
{{- if not (and .Values.tls.enabled .Values.tls.zookeeper.enabled) -}}
{{ template "pulsar.zookeeper.service" . }}:{{ .Values.zookeeper.ports.client }}
{{- end -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled -}}
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
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
/pulsar/keytool/keytool.sh zookeeper {{ template "pulsar.zookeeper.hostname" . }} false;
{{- end }}
{{- end }}

{{/*
Define zookeeper certs mounts
*/}}
{{- define "pulsar.zookeeper.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
- mountPath: "/pulsar/certs/zookeeper"
  name: zookeeper-certs
  readOnly: true
- mountPath: "/pulsar/certs/ca"
  name: ca
  readOnly: true
- name: keytool
  mountPath: "/pulsar/keytool/keytool.sh"
  subPath: keytool.sh
{{- end }}
{{- end }}

{{/*
Define zookeeper certs volumes
*/}}
{{- define "pulsar.zookeeper.certs.volumes" -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
- name: zookeeper-certs
  secret:
    secretName: "{{ template "pulsar.fullname" . }}-{{ .Values.tls.zookeeper.cert_name }}"
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
{{- end}}
{{- end }}


{{/*
Define zookeeper log mounts
*/}}
{{- define "pulsar.zookeeper.log.volumeMounts" -}}
- mountPath: "{{ template "pulsar.home" .}}/conf"
  name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}"
{{- end }}

{{/*
Define zookeeper log volumes
*/}}
{{- define "pulsar.zookeeper.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}"
    items:
    - key: log4j2.yaml
      path: log4j2.yaml
{{- end }}
