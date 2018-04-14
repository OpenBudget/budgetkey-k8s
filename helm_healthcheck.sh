#!/usr/bin/env bash

source connect.sh

RES=0

echo "Performing health checks for all charts of ${K8S_ENVIRONMENT_NAME} environment"

socialmap_healthcheck() {
    ! [ "`./read_env_yaml.sh socialmap enabled`" == "true" ] \
        && echo "socialmap chart is disabled, skipping healthcheck" && return 0
    kubectl rollout status deployment/socialmap-main-page
}

openprocure_healthcheck() {
    ! [ "`./read_env_yaml.sh openprocure enabled`" == "true" ] \
        && echo "openprocure chart is disabled, skipping healthcheck" && return 0
    kubectl rollout status deployment/openprocure-main-page
}

themes_healthcheck() {
    ! [ "`./read_env_yaml.sh themes enabled`" == "true" ] \
        && echo "themes chart is disabled, skipping healthcheck" && return 0
    kubectl rollout status daemonset themes
}

nginx_healthcheck() {
    ! [ "`./read_env_yaml.sh nginx enabled`" == "true" ] \
        && echo "nginx chart is disabled, skipping healthcheck" && return 0
    kubectl rollout status deployment/nginx
}

postgres_healthcheck() {
    ! [ "`./read_env_yaml.sh postgres enabled`" == "true" ] \
        && echo "postgres chart is disabled, skipping healthcheck" && return 0
    kubectl rollout status deployment/postgres
}

elasticsearch_healthcheck() {
    ! [ "`./read_env_yaml.sh elasticsearch enabled`" == "true" ] \
        && echo "elasticsearch chart is disabled, skipping healthcheck" && return 0
    kubectl rollout status deployment/elasticsearch
}

db_backup_healthcheck() {
    ! [ "`./read_env_yaml.sh db-backup enabled`" == "true" ] \
        && echo "db-backup chart is disabled, skipping healthcheck" && return 0
    [ "`./read_env_yaml.sh db-backup secretName`" == "" ] \
        && echo "db-backup is not set, skipping healthcheck" && return 0
    kubectl rollout status deployment/db-backup
}

! socialmap_healthcheck && echo failed socialmap healthcheck && RES=1;
! themes_healthcheck && echo failed themes healthcheck && RES=1;
! openprocure_healthcheck && echo failed openprocure healthcheck && RES=1;
! nginx_healthcheck && echo failed nginx healthcheck && RES=1;
! postgres_healthcheck && echo failed postgres healthcheck && RES=1;
! elasticsearch_healthcheck && echo failed elasticsearch healthcheck && RES=1;
! db_backup_healthcheck && echo failed db-bcakup healthcheck && RES=1;

[ "${RES}" == "0" ] && echo Great Success!

exit $RES
