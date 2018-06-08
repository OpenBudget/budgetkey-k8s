#!/bin/sh
kubectl exec -it $(kubectl get pods -l app=postgres -o 'jsonpath={.items[0].metadata.name}') \
    -- bash -c 'cd ~postgres && su postgres sh -c "psql budgetkey"'
