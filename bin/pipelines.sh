#!/bin/sh
kubectl -n budgetkey exec -it $(kubectl -n budgetkey get pods -l app=pipelines -o 'jsonpath={.items[0].metadata.name}') sh
