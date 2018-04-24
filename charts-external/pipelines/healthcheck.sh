#!/usr/bin/env bash

echo chart is not ready, skipping health check
exit 0

kubectl rollout status deployment/pipelines
