{{/*
Expand the name of the chart.
*/}}
{{- define "pontoon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pontoon.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pontoon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pontoon.labels" -}}
helm.sh/chart: {{ include "pontoon.chart" . }}
{{ include "pontoon.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pontoon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pontoon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pontoon.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pontoon.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "postgres.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgres" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "rabbitmq.fullname" -}}
{{- printf "%s-%s" .Release.Name "rabbitmq" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pontoon.database_url" -}}
{{- if .Values.postgres.enabled }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      key: postgresql-password
      name: {{ include "postgres.fullname" . }}
- name: DATABASE_URL
  value: "{{ printf "postgres://%s:$(DATABASE_PASSWORD)@%s/%s" .Values.postgres.postgresqlUsername  (include "postgres.fullname" .) .Values.postgres.postgresqlDatabase }}"
{{- end }}
{{- end }}

{{- define "pontoon.rabbitmq_url" -}}
{{- if .Values.postgres.enabled }}
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
      key: rabbitmq-password
      name: {{ include "rabbitmq.fullname" . }}
- name: RABBITMQ_URL
  value: "{{ printf "amqp://%s:$(RABBITMQ_PASSWORD)@%s-headless/" .Values.rabbitmq.auth.username  (include "rabbitmq.fullname" .) }}"
{{- end }}
{{- end }}

{{/* vim: set filetype=mustache: */}}
{{/*
Renders a value that contains template.
Usage:
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}
