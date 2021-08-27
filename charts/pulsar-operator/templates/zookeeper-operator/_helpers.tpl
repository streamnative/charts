{{/*
install crd yaml file to tpl
*/}}
{{- define "zookeeper.crd" -}}
{{- $files := .Files }}
{{ $files.Get "crds/zookeeper.streamnative.io_zookeeperclusters" }}
{{- end -}}
