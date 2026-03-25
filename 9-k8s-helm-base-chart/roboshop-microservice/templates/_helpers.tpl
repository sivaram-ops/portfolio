{{/* Common labels */}}
{{- define "roboshop.labels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: roboshop
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "roboshop.selectorLabels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
{{- end }}

{{/* Common Resource Name */}}
{{- define "roboshop.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride -}}
{{- else -}}
{{- .Release.Name -}}
{{- end -}}
{{- end -}}