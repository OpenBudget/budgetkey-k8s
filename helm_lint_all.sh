#!/usr/bin/env bash

RES=0

echo "Linting all charts"
for CHART_NAME in `ls charts-external`; do
    if [ "$(eval echo `./read_yaml.py "charts-external/${CHART_NAME}/Chart.yaml" apiVersion 2>/dev/null`)" == "v2" ]; then
      HELM_BIN=helm3
    else
      HELM_BIN=helm
    fi
    $HELM_BIN lint charts-external/$CHART_NAME 2>/dev/null | grep 'ERROR' | grep -v 'Chart.yaml: version is required'
    if [ "$?" == "0" ]; then
        echo "${CHART_NAME}: failed lint"
        RES=1
    else
        echo "${CHART_NAME}: OK"
    fi
done

exit $RES
