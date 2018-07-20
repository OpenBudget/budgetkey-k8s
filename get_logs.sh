#!/usr/bin/env bash

if [ "${1}" == "--pause" ]; then
    PAUSE=1
    PARAMS="${@:2}"
else
    PAUSE=0
    PARAMS="$@"
fi

LOG_LABELS="app=app-generic-item
            app=app-main-page
            app=app-profile
            app=app-about
            app=app-search
            app=emails
            app=auth
            app=data-api
            app=db-backup
            app=elasticsearch
            app=kibana
            app=list-manager
            app=nginx
            app=pipelines
            app=postgres
            app=search-api
            app=socialmap-app-main-page
            app=openprocure-app-main-page
            app=themes"

for label in $LOG_LABELS; do
    echo "${label}"
    kubectl logs -l "${label}" $PARAMS
    [ "${PAUSE}" == "1" ] && read -p "Press <Return> to continue..."
done
