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

{{/*Define the image for pulsar*/}}
{{- define "pulsar.image" -}}
{{ .Values.images.registry | default .Values.images.pulsar.registry }}/{{ .Values.images.pulsar.repository }}:{{ .Values.images.pulsar.tag | default .Values.images.tag }}
{{- end -}}