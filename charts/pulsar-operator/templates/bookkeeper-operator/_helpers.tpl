{{/*
install crd yaml file to tpl.
*/}}
{{- define "bookkeeper.crd" -}}
{{- $files := .Files }}
{{ $files.Get "crds/bookkeeper.streamnative.io_bookkeeperclusters.yaml" }}
{{- end -}}
