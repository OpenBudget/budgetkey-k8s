#!/bin/sh
kubectl -n budgetkey delete pods `kubectl -n budgetkey get pods -o=custom-columns=Name:.metadata.name | grep pipelines`
