{{- define "pulsar.openshift.scc.name" -}}
{{ template "pulsar.namespace" . }}-{{ template "pulsar.fullname" . }}-openshift-scc
{{- end -}}