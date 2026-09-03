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

{{/*
Common environment variables of the Dakara server services
*/}}
{{- define "dakara.env" -}}
- name: DAKARA_DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.cnpg.secretName }}
      key: uri
- name: DAKARA_REDIS_URL
  value: {{ required "redis.host is required" .Values.redis.host | quote }}
- name: DAKARA_ALLOWED_HOSTS
  value: {{ .Values.allowedHosts | default .Values.ingress.host | default "*" | quote }}
- name: DAKARA_HOST_URL
  value: {{ .Values.hostUrl | default (printf "https://%s" .Values.ingress.host) | quote }}
- name: DAKARA_SECRET_KEY
  value: {{ .Values.secretKey | quote }}
- name: DAKARA_TIME_ZONE
  value: {{ .Values.timeZone | default "UTC" | quote }}
- name: DAKARA_LOG_TO_CONSOLE
  value: "True"
# the logfile handler is still configured by Django even when unused,
# point it to a writable path since there is no persistent /data
- name: DAKARA_LOG_FILE_PATH
  value: "/tmp/dakara_server.log"
{{- if .Values.smtp.enabled }}
- name: DAKARA_EMAIL_ENABLED
  value: "True"
- name: DAKARA_SENDER_EMAIL
  value: {{ .Values.smtp.sender | quote }}
- name: DAKARA_EMAIL_URL
  valueFrom:
    secretKeyRef:
      name: "{{ .Release.Name }}-smtp"
      key: DAKARA_EMAIL_URL
{{- end }}
{{- end -}}

{{/*
Superuser environment variables, only used by the init job
*/}}
{{- define "dakara.superuserEnv" -}}
- name: DAKARA_SUPERUSER_USERNAME
  value: {{ .Values.superuser.username | default "admin" | quote }}
- name: DAKARA_SUPERUSER_EMAIL
  value: {{ .Values.superuser.email | default "admin@localhost" | quote }}
- name: DAKARA_SUPERUSER_PASSWORD
  value: {{ required "superuser.password is required" .Values.superuser.password | quote }}
{{- end -}}

{{/*
Volume installing psycopg into an emptyDir (upstream image is MySQL only)
*/}}
{{- define "dakara.pylibsVolume" -}}
- name: pylibs
  emptyDir: {}
{{- end -}}

{{/*
Init container installing psycopg into the pylibs volume
*/}}
{{- define "dakara.pylibsInitContainer" -}}
- name: pylibs
  image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
  imagePullPolicy: "{{ .Values.image.pullPolicy }}"
  command: ["pip", "install", "--target", "/pylibs", {{ .Values.psycopg.requirement | quote }}]
  volumeMounts:
    - name: pylibs
      mountPath: /pylibs
{{- end -}}

{{/*
Environment pointing Python to the psycopg install in the pylibs volume
*/}}
{{- define "dakara.pylibsEnv" -}}
- name: PYTHONPATH
  value: "/pylibs"
{{- end -}}
