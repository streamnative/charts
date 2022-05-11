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
{{ .Values.images.registry | default .Values.images.pulsar.registry }}/{{ .Values.images.pulsar.repository }}:{{ .Values.images.tag | default .Values.images.pulsar.tag }}
{{- end -}}


{{/*
Define the role kind for pulsar operator
*/}}
{{- define "pulsar.operatorRoleKind" -}}
{{ if .Values.pulsar.serviceAccount.clusterRole }}
{{- print "ClusterRole"  -}}
{{- else -}}
{{- print "Role"  -}}
{{- end -}}
{{- end -}}


{{/*
Define the rolebinding kind for pulsar operator
*/}}
{{- define "pulsar.operatorRoleBindingKind" -}}
{{ if .Values.pulsar.serviceAccount.clusterRole }}
{{- print "ClusterRoleBinding"  -}}
{{- else -}}
{{- print "RoleBinding"  -}}
{{- end -}}
{{- end -}}

{{/*
Define the rolebinding name for pulsar operator
*/}}
{{- define "pulsar.operatorRoleBindingName" -}}
{{ if .Values.pulsar.serviceAccount.clusterRole }}
{{- printf "%s-%s-clusterrolebinding" (include "pulsar.fullname" .) .Values.pulsar.rbac.name  -}}
{{- else -}}
{{- printf "%s-%s-rolebinding" (include "pulsar.fullname" .) .Values.pulsar.rbac.name  -}}
{{- end -}}
{{- end -}}