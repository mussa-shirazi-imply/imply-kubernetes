{{- define "imply.chart.name" -}}
{{- trimSuffix "-lts" .Chart.Name -}}
{{- end -}}

{{- define "imply.name" -}}
{{- default (include "imply.chart.name" .) .Values.nameOverride | trunc 43 | trimSuffix "-" -}}
{{- end -}}

{{- define "imply.manager.name" -}}
{{- printf "%s-manager" (include "imply.name" .) -}}
{{- end -}}

{{- define "imply.manager.internalService.name" -}}
{{- printf "%s-manager-int" (include "imply.name" .) -}}
{{- end -}}

{{- define "imply.master.name" -}}
{{- printf "%s-master" (include "imply.name" .) -}}
{{- end -}}

{{- define "imply.query.name" -}}
{{- printf "%s-query" (include "imply.name" .) -}}
{{- end -}}

{{- define "imply.dataTier1.name" -}}
{{- printf "%s-data" (include "imply.name" .) -}}
{{- end -}}

{{- define "imply.dataTier2.name" -}}
{{- printf "%s-data-two" (include "imply.name" .) -}}
{{- end -}}

{{- define "imply.dataTier3.name" -}}
{{- printf "%s-data-three" (include "imply.name" .) -}}
{{- end -}}

{{- define "imply.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 51 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default (include "imply.chart.name" .) .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 51 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 43 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "imply.manager.fullname" -}}
{{- printf "%s-manager" (include "imply.fullname" .) -}}
{{- end -}}

{{- define "imply.manager.internalService.fullname" -}}
{{- printf "%s-manager-int" (include "imply.fullname" .) -}}
{{- end -}}

{{- define "imply.master.fullname" -}}
{{- printf "%s-master" (include "imply.fullname" .) -}}
{{- end -}}

{{- define "imply.query.fullname" -}}
{{- printf "%s-query" (include "imply.fullname" .) -}}
{{- end -}}

{{- define "imply.pivot.ingressName" -}}
{{- printf "%s-pivot-ingress" (include "imply.fullname" .) -}}
{{- end -}}

{{- define "imply.router.ingressName" -}}
{{- printf "%s-router-ingress" (include "imply.fullname" .) -}}
{{- end -}}

{{- define "imply.dataTier1.fullname" -}}
{{- printf "%s-data" (include "imply.fullname" .) -}}
{{- end -}}

{{- define "imply.dataTier2.fullname" -}}
{{- printf "%s-data-two" (include "imply.fullname" .) -}}
{{- end -}}

{{- define "imply.dataTier3.fullname" -}}
{{- printf "%s-data-three" (include "imply.fullname" .) -}}
{{- end -}}

{{- define "imply.storage.fullname" -}}
{{- printf "%s-deep-storage" (include "imply.fullname" .) -}}
{{- end -}}

{{- define "imply.scripts.fullname" -}}
{{- printf "%s-scripts" (include "imply.fullname" .) -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "imply.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "imply.labels" -}}
app.kubernetes.io/name: {{ include "imply.name" . }}
helm.sh/chart: {{ include "imply.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common Probes

Kubernetes assumes that it is the only system controlling pods, however this is not
the case when Imply Cloud manager is managing Imply clusters.  When the manager is
performing actions on the cluster such as creation or upgrade we do not want kubernetes
to restart a pod for any reason.

These probes call a script that allows us to include Imply cluster state information in the
probe.  The script will only return a failure in the case that Imply services are unavailable
on the agent and the cluster is in the RUNNING state.  If the cluster state can not be determined
for any reason (i.e manager is down) the script does not return a failure
*/}}

{{- define "imply.probe.livenessProbe" -}}
exec:
  command:
    - /bin/sh
    - -c
    - /root/check-health -c "{{ .Values.agents.clusterName }}" {{ ternary "" "-s" (empty .Values.security.tls) }}
timeoutSeconds: 10
{{- end -}}

{{- define "imply.probe.startupProbe" -}}
exec:
  command:
    - /bin/sh
    - -c
    - /root/readiness-check
failureThreshold: 90
periodSeconds: 10
{{- end -}}

{{- define "imply.probe.readinessProbe" -}}
exec:
  command:
    - /bin/sh
    - -c
    - /root/readiness-check
periodSeconds: 2
timeoutSeconds: 2
{{- end -}}
