#!/usr/bin/env bash

echo dependencies:
for DIRNAME in `ls charts-external/`; do
  if [ "${DIRNAME}" != "db-backup" ] && [ "${DIRNAME}" != "elasticsearch" ]; then
    echo "- name: ${DIRNAME}"
    echo "  version: v0.0.0"
    echo "  repository: file://charts-external/${DIRNAME}"
  fi
done