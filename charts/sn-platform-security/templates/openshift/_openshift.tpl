{{- define "pulsar.openshift.scc" -}}
{{- $defaultSCC := printf "%s-%s-openshift-scc" (include "pulsar.namespace" .) (include "pulsar.fullname" .) -}}
{{- .Values.openshift.scc.name | default $defaultSCC }}
{{- end -}}

{{- define "pulsar.openshift.role" -}}
{{- printf "%s-%s-openshift-role" (include "pulsar.namespace" .) (include "pulsar.fullname" .) }}
{{- end -}}

{{- define "pulsar.openshift.rolebinding" -}}
{{- printf "%s-%s-openshift-rolebinding" (include "pulsar.namespace" .) (include "pulsar.fullname" .) }}
{{- end -}}