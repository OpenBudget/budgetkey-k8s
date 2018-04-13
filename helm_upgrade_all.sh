#!/usr/bin/env bash

source connect.sh

RES=0

echo "Upgrading all charts of ${K8S_ENVIRONMENT_NAME} environment"

! ./helm_upgrade.sh "$@" && echo 'failed helm upgrade' && RES=1;
! ./helm_upgrade_external_chart.sh socialmap "$@" && echo "failed socialmap upgrade" && RES=1;

exit $RES
