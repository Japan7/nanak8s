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

{{- define "gel.env" -}}
- name: GEL_SERVER_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-gel
      key: username
- name: GEL_SERVER_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-gel
      key: password
- name: GEL_DSN
  value: gel://$(GEL_SERVER_USER):$(GEL_SERVER_PASSWORD)@{{ .Values.gel.service }}/{{ .Values.gel.database }}
- name: GEL_CLIENT_SECURITY
  value: insecure_dev_mode
{{- end -}}

{{- define "tasks.affinity" -}}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
            - key: app.kubernetes.io/name
              operator: In
              values:
                - {{ include "common.names.name" . }}
            - key: app.kubernetes.io/instance
              operator: In
              values:
                - {{ .Release.Name }}
            - key: app.kubernetes.io/component
              operator: In
              values:
                - api
                - tasks
            - key: app.kubernetes.io/part-of
              operator: In
              values:
                - {{ .Chart.Name }}
        topologyKey: kubernetes.io/hostname
{{- end -}}
