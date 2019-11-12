#!/bin/sh
kubectl delete pods `kubectl get pods -o=custom-columns=Name:.metadata.name | grep pipelines`
