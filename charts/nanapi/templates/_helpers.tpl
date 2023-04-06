{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "common.names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Kubernetes standard labels
*/}}
{{- define "common.labels.standard" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "common.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "edgedb.env" -}}
- name: EDGEDB_SERVER_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-edgedb
      key: username
- name: EDGEDB_SERVER_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-edgedb
      key: password
- name: EDGEDB_DSN
  value: edgedb://$(EDGEDB_SERVER_USER):$(EDGEDB_SERVER_PASSWORD)@{{ .Values.edgedb.service }}/{{ .Values.edgedb.database }}
- name: EDGEDB_CLIENT_SECURITY
  value: insecure_dev_mode
{{- end -}}
