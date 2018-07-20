#!/bin/sh
kubectl exec -it $(kubectl get pods -l app=pipelines -o 'jsonpath={.items[0].metadata.name}') sh
