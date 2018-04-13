#!/usr/bin/env bash

source connect.sh

RES=0

echo "Upgrading all charts of ${K8S_ENVIRONMENT_NAME} environment"

! ./helm_upgrade_external_chart.sh socialmap "$@" && echo "failed socialmap upgrade" && RES=1;
! ./helm_upgrade_external_chart.sh openprocure "$@" && echo "failed openprocure upgrade" && RES=1;
! ./helm_upgrade_external_chart.sh themes "$@" "$@" && echo "failed themes upgrade" && RES=1;
! ./helm_upgrade_external_chart.sh nginx "$@" "$@" && echo "failed nginx upgrade" && RES=1;
! ./helm_upgrade_external_chart.sh postgres "$@" "$@" && echo "failed postgres upgrade" && RES=1;
! ./helm_upgrade_external_chart.sh elasticsearch "$@" "$@" && echo "failed elasticsearch upgrade" && RES=1;

exit $RES
