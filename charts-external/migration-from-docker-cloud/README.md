# Migration from Docker Cloud

## Postgres

* clear existing data

```
NODE_NAME=`kubectl get pod -lapp=postgres '-ojsonpath={.items[0].spec.nodeName}'`
kubectl delete deployment postgres
utils/ops-pod/run.sh ori-ops node=${NODE_NAME},gcepd=budgetkey-postgres-data -- sh -c 'rm -rf /gcepd/*'
```

* stop writes to old DB
* enable the db migration job and set relevant values under `migration-from-docker-cloud`
* `./helm_upgrade_external_chart.sh migration-from-docker-cloud`
* Wait for job to complete - `kubectl get job db-migration`
* `./helm_upgrade_external_chart.sh postgres`

## Elasticsearch

* clear existing data - same as for postgres
* stop writes to old Elasticsearch
* enable and run the migration job - same as for postgres

## Datapackages

* enable and run the migration job - wait for completion
* enable and run the datapackage permissions job

