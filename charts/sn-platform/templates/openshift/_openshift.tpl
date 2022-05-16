{{- define "pulsar.openshift.scc.name" -}}
{{ template "pulsar.fullname" . }}-openshift-scc
{{- end -}}