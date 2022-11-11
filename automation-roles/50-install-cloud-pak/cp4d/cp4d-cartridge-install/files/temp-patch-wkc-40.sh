#!/bin/bash

# Parameters
# $1: Status directory
# $2: OpenShift project for Cloud Pak for Data

status_dir=$1
project=$2

exit_code=0

get_logtime() {
  echo $(date "+%Y-%m-%d %H:%M:%S")
}

log() {
  LOG_TIME=$(get_logtime)
  printf "[${LOG_TIME}] ${1}\n" | tee -a ${status_dir}/log/$project-wkc-40-patch.log
}

log "----------"
# Check if the connection to the OpenShift cluster is still valid
log "Info: Checking access to project $project"
oc get project $project
if [ $? -ne 0 ];then
  log "Error: Could not access project $project. Has the OpenShift login token expired?"
  exit 99
fi

while true;do
  log "----------"
  log "Checking UG CR"
  log "----------"

  if oc get UG -n ${project} ug-cr;then
    log "Info: Patch UG ug-cr"
    oc patch WKC wkc-cr \
     -n ${project} \ 
     --type merge \
     -p '{
      "spec": {
          "gov_ui_resources": {
              "requests": {
                  "cpu": "10m",
                  "memory": "50Mi"
              },
              "limits": {
                  "cpu": "500m",
                  "memory": "500Mi"
              }
          },
          "quality_ui_resources": {
              "requests": {
                  "cpu": "10m",
                  "memory": "80Mi"
              },
              "limits": {
                  "cpu": "500m",
                  "memory": "500Mi"
              }
          },
          "enterprise_search_ui_resources": {
              "requests": {
                  "cpu": "10m",
                  "memory": "50Mi"
              },
              "limits": {
                  "cpu": "500m",
                  "memory": "500Mi"
              }
          },
          "admin_ui_resources": {
              "requests": {
                  "cpu": "10m",
                  "memory": "80Mi"
              },
              "limits": {
                  "cpu": "500m",
                  "memory": "500Mi"
              }
          },
          "igc_ui_resources": {
              "requests": {
                  "cpu": "10m",
                  "memory": "50Mi"
              },
              "limits": {
                  "cpu": "500m",
                  "memory": "500Mi"
              }
          }
      }
    }' | tee -a ${status_dir}/log/$project-wkc-40-patch.log
  fi

  log "----------"
  log "Finished checks, sleeping for 5 minutes"
  sleep 120
done
exit 0
