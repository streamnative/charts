{{/*
install crd yaml file to tpl.
*/}}
{{- define "bookkeeper.crd" -}}
{{- $files := .Files }}
{{ $files.Get "crds/bookkeeper.streamnative.io_bookkeeperclusters.yaml" }}
{{- end -}}

{{/*Define the image for bookkeeper*/}}
{{- define "bookkeeper.image" -}}
{{ .Values.images.registry | default .Values.images.bookkeeper.registry }}/{{ .Values.images.bookkeeper.repository }}:{{ .Values.images.bookkeeper.tag | default .Values.images.tag }}
{{- end -}}