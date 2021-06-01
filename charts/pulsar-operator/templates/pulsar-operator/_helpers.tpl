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
