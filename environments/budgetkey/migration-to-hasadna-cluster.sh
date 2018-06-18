#!/usr/bin/env bash

create_source_snapshot() {
    gcloud compute disks snapshot "${1}" --snapshot-names="${1}-migration-to-hasadna-cluster-3" \
                                         --project=next-obudget-org --zone=europe-west1-b
}

get_source_snapshot_selfLink() {
    gcloud compute snapshots describe "${1}-migration-to-hasadna-cluster-3" --project=next-obudget-org --format json \
        | jq -r .selfLink
}

create_new_disk() {
    gcloud compute disks create "${1}-3" --source-snapshot=$(get_source_snapshot_selfLink "${1}") \
                                         --project=hasadna-general --zone=europe-west1-b
}

copy_secret() {
    kubectl --context=gke_next-obudget-org_europe-west1-b_budgetkey --namespace=budgetkey \
        get secret "${1}" -o json \
        | jq '.metadata.namespace = "budgetkey"' \
    | kubectl --context=gke_hasadna-general_europe-west1-b_hasadna-cluster --namespace=budgetkey \
        create -f -
}

create_source_snapshot budgetkey-elasticsearch-data
create_source_snapshot budgetkey-postgres-data

create_new_disk budgetkey-elasticsearch-data
create_new_disk budgetkey-postgres-data

kubectl --context=gke_hasadna-general_europe-west1-b_hasadna-cluster create ns budgetkey

copy_secret auth
copy_secret data-api
copy_secret db-backup
copy_secret list-manager
copy_secret pipelines
copy_secret postgres

gcloud --project=next-obudget-org compute disks create --size=100GB --zone=europe-west1-b budgetkey-pipelines-data-2

echo 'apiVersion: "v1"
kind: "Pod"
metadata:
  name: copy-data-to-persistent-disk
spec:
  nodeSelector:
    kubernetes.io/hostname: gke-budgetkey-default-pool-bfb61637-qzv3
  containers:
  - name: "ops"
    image: alpine
    command:
    - sh
    - "-c"
    - while true; do sleep 86400; done
    volumeMounts:
    - name: hostpath-var
      mountPath: /hostpath/var
    - name: gcepd
      mountPath: /gcepd
  volumes:
  - name: hostpath-var
    hostPath:
      path: /var
      type: Directory
  - name: gcepd
    gcePersistentDisk:
      pdName: budgetkey-pipelines-data' \
  | kubectl --context=gke_next-obudget-org_europe-west1-b_budgetkey --namespace=budgetkey create -f -

while [ "$(kubectl --context=gke_next-obudget-org_europe-west1-b_budgetkey --namespace=budgetkey \
    get pod copy-data-to-persistent-disk -o json | jq -r .status.phase)" != "Running" ]; do sleep 1; echo .; done

kubectl --context=gke_next-obudget-org_europe-west1-b_budgetkey --namespace=budgetkey \
    exec -it copy-data-to-persistent-disk cp -r /hostpath/var/budgetkey-persistent-data /gcepd/budgetkey-persistent-data

kubectl --context=gke_next-obudget-org_europe-west1-b_budgetkey --namespace=budgetkey delete pod copy-data-to-persistent-disk

create_source_snapshot budgetkey-pipelines-data && create_new_disk budgetkey-pipelines-data

kubectl --context=gke_hasadna-general_europe-west1-b_hasadna-cluster label node gke-hasadna-cluster-default-pool-17373db3-dlpj \
                                                                                hasadna/hostpath-persistence=budgetkey-persistent-data

echo 'apiVersion: "v1"
kind: "Pod"
metadata:
  name: copy-data-from-persistent-disk
spec:
  nodeSelector:
    hasadna/hostpath-persistence: budgetkey-pipelines-data
  containers:
  - name: "ops"
    image: alpine
    command:
    - sh
    - "-c"
    - while true; do sleep 86400; done
    volumeMounts:
    - name: hostpath-var
      mountPath: /hostpath/var
    - name: gcepd
      mountPath: /gcepd
  volumes:
  - name: hostpath-var
    hostPath:
      path: /var
      type: Directory
  - name: gcepd
    gcePersistentDisk:
      pdName: budgetkey-pipelines-data' \
  | kubectl --context=gke_hasadna-general_europe-west1-b_hasadna-cluster --namespace=budgetkey create -f -

while [ "$(kubectl --context=gke_hasadna-general_europe-west1-b_hasadna-cluster --namespace=budgetkey \
    get pod copy-data-from-persistent-disk -o json | jq -r .status.phase)" != "Running" ]; do sleep 1; echo .; done

kubectl --context=gke_hasadna-general_europe-west1-b_hasadna-cluster --namespace=budgetkey \
    exec -it copy-data-from-persistent-disk cp -r /gcepd/budgetkey-persistent-data /hostpath/var/budgetkey-persistent-data

kubectl --context=gke_hasadna-general_europe-west1-b_hasadna-cluster --namespace=budgetkey delete pod copy-data-from-persistent-disk

echo 'apiVersion: "v1"
kind: "Pod"
metadata:
  name: copy-data-from-persistent-disk
spec:
  nodeSelector:
    hasadna/hostpath-persistence: budgetkey-pipelines-data
  containers:
  - name: "ops"
    image: alpine
    command:
    - sh
    - "-c"
    - while true; do sleep 86400; done
    volumeMounts:
    - name: hostpath-var
      mountPath: /hostpath/var
    - name: gcepd
      mountPath: /gcepd
  volumes:
  - name: hostpath-var
    hostPath:
      path: /var
      type: Directory
  - name: gcepd
    gcePersistentDisk:
      pdName: budgetkey-pipelines-data' \
  | kubectl --context=gke_hasadna-general_europe-west1-b_hasadna-cluster --namespace=budgetkey create -f -

while [ "$(kubectl --context=gke_hasadna-general_europe-west1-b_hasadna-cluster --namespace=budgetkey \
    get pod copy-data-from-persistent-disk -o json | jq -r .status.phase)" != "Running" ]; do sleep 1; echo .; done

kubectl --context=gke_hasadna-general_europe-west1-b_hasadna-cluster --namespace=budgetkey exec -it copy-data-from-persistent-disk -- sh -c '
    chown -R 1000:1000 /hostpath/var/budgetkey-persistent-data/datapackages;
    chown 1000:1000 /hostpath/var/budgetkey-persistent-data/.ssh/* && chmod 400 /hostpath/var/budgetkey-persistent-data/.ssh/*;
    chown -R 1000:1000 /hostpath/var/budgetkey-persistent-data/redis;
'
