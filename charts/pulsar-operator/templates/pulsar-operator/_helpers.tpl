{{/*
install broker crd yaml file to tpl.
*/}}
{{- define "broker.crd" -}}
{{- $files := .Files }}
{{ $files.Get "crds/pulsar.streamnative.io_pulsarbrokers" }}
{{- end -}}

{{/*
install proxy crd yaml file to tpl.
*/}}
{{- define "proxy.crd" -}}
{{- $files := .Files }}
{{ $files.Get "crds/pulsar.streamnative.io_pulsarproxies" }}
{{- end -}}

{{/*
install connection crd yaml file to tpl.
*/}}
{{- define "connection.crd" -}}
{{- $files := .Files }}
{{ $files.Get "crds/pulsar.streamnative.io_pulsarconnections" }}
{{- end -}}

{{/*
install tenant crd yaml file to tpl.
*/}}
{{- define "tenant.crd" -}}
{{- $files := .Files }}
{{ $files.Get "crds/pulsar.streamnative.io_pulsartenants" }}
{{- end -}}

{{/*
install connection crd yaml file to tpl.
*/}}
{{- define "namespace.crd" -}}
{{- $files := .Files }}
{{ $files.Get "crds/pulsar.streamnative.io_pulsarnamespaces" }}
{{- end -}}

{{/*
install connection crd yaml file to tpl.
*/}}
{{- define "topic.crd" -}}
{{- $files := .Files }}
{{ $files.Get "crds/pulsar.streamnative.io_pulsartopics" }}
{{- end -}}
