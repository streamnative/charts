{{/*
install crd yaml file to tpl.
*/}}
{{- define "bookkeeper.crd" -}}
{{- $files := .Files }}
{{ $files.Get "crds/bookkeeper.streamnative.io_bookkeeperclusters.yaml" }}
{{- end -}}

{{/*Define the image for bookkeeper*/}}
{{- define "bookkeeper.image" -}}
{{ .Values.images.registry | default .Values.images.bookkeeper.registry }}/{{ .Values.images.bookkeeper.repository }}:{{ .Values.images.tag | default .Values.images.bookkeeper.tag }}
{{- end -}}

{{/*
Define the role kind for bookkeeper operator
*/}}
{{- define "pulsar.bookkeeperRoleKind" -}}
{{ if .Values.bookkeeper.serviceAccount.clusterRole }}
{{- print "ClusterRole"  -}}
{{- else -}}
{{- print "Role"  -}}
{{- end -}}
{{- end -}}


{{/*
Define the rolebinding kind for bookkeeper operator
*/}}
{{- define "pulsar.bookkeeperRoleBindingKind" -}}
{{ if .Values.bookkeeper.serviceAccount.clusterRole }}
{{- print "ClusterRoleBinding"  -}}
{{- else -}}
{{- print "RoleBinding"  -}}
{{- end -}}
{{- end -}}


{{/*
Define the rolebinding name for bookkeeper operator
*/}}
{{- define "pulsar.bookkeeperRoleBindingName" -}}
{{ if .Values.bookkeeper.serviceAccount.clusterRole }}
{{- printf "%s-%s-clusterrolebinding" (include "pulsar.fullname" .) .Values.bookkeeper.rbac.name  -}}
{{- else -}}
{{- printf "%s-%s-rolebinding" (include "pulsar.fullname" .) .Values.bookkeeper.rbac.name  -}}
{{- end -}}
{{- end -}}