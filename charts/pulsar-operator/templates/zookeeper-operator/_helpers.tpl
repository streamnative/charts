{{/*
install crd yaml file to tpl
*/}}
{{- define "zookeeper.crd" -}}
{{- $files := .Files }}
{{ $files.Get "crds/zookeeper.streamnative.io_zookeeperclusters.yaml" }}
{{- end -}}

{{/*Define the image for zookeeper*/}}
{{- define "zookeeper.image" -}}
{{ .Values.images.registry | default .Values.images.zookeeper.registry }}/{{ .Values.images.zookeeper.repository }}:{{ .Values.images.tag | default .Values.images.zookeeper.tag }}
{{- end -}}


{{/*
Define the role kind for zookeeper operator
*/}}
{{- define "pulsar.zookeeperRoleKind" -}}
{{ if .Values.zookeeper.serviceAccount.clusterRole }}
{{- print "ClusterRole"  -}}
{{- else -}}
{{- print "Role"  -}}
{{- end -}}
{{- end -}}


{{/*
Define the rolebinding kind for zookeeper operator
*/}}
{{- define "pulsar.zookeeperRoleBindingKind" -}}
{{ if .Values.zookeeper.serviceAccount.clusterRole }}
{{- print "ClusterRoleBinding"  -}}
{{- else -}}
{{- print "RoleBinding"  -}}
{{- end -}}
{{- end -}}

{{/*
Define the rolebinding name for zookeeper operator
*/}}
{{- define "pulsar.zookeeperRoleBindingName" -}}
{{ if .Values.zookeeper.serviceAccount.clusterRole }}
{{- printf "%s-%s-clusterrolebinding" (include "pulsar.fullname" .) .Values.zookeeper.rbac.name  -}}
{{- else -}}
{{- printf "%s-%s-rolebinding" (include "pulsar.fullname" .) .Values.zookeeper.rbac.name  -}}
{{- end -}}
{{- end -}}