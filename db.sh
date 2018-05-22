#!/bin/sh
kubectl exec -it `kubectl get pods | grep postgres | cut -c-40` -- bash -c 'cd ~postgres && su postgres sh -c "psql budgetkey"'
