{{/*
install crd yaml file to tpl
*/}}
{{- define "zookeeper.crd" -}}
{{- $files := .Files }}
{{ $files.Get "crds/zookeeper.streamnative.io_zookeeperclusters" }}
{{- end -}}

{{/*Define the image for zookeeper*/}}
{{- define "zookeeper.image" -}}
{{ .Values.images.registry | default .Values.images.zookeeper.registry }}/{{ .Values.images.zookeeper.repository }}:{{ .Values.images.zookeeper.tag | default .Values.images.tag }}
{{- end -}}