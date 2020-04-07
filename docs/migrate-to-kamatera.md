# Migration to Kamatera

Create NFS paths (run on NFS server):

```
mkdir -p /srv/default2/budgetkey/elasticsearch /srv/default2/budgetkey/elasticsearch-new &&\
mkdir -p /srv/default2/budgetkey/pipelines /srv/default2/budgetkey/postgres
```

Connect to the Gcloud environment and export the secrets:

```
export KUBECONFIG=
source switch_environment.sh budgetkey-gke
mkdir -p environments/budgetkey/.secrets
for secret in auth budgetkey-elasticsearch data-api db-backup dgp-server emails help list-manager pipelines postgres postgres-dns-updater; do
    kubectl get secret $secret --export -o yaml > environments/budgetkey/.secrets/$secret.yaml
done
```

Connect to the Kamatera environment, create the namespace and import the secrets

```
export KUBECONFIG=/path/to/kamatera/kubeconfig
source switch_environment.sh budgetkey
kubectl create ns budgetkey
for secret in auth budgetkey-elasticsearch data-api db-backup dgp-server emails help list-manager pipelines postgres postgres-dns-updater; do
    kubectl -n budgetkey apply -f environments/budgetkey/.secrets/$secret.yaml
done
rm -rf environments/budgetkey/.secrets
```

Migrate data

```
export KUBECONFIG=
source switch_environment.sh budgetkey-gke &&\
source functions.sh &&\
ELASTICSEARCH_SOURCE_DIR=/var/lib/kubelet/plugins/kubernetes.io/gce-pd/mounts/budgetkey-elasticsearch-data-2 &&\
ELASTICSEARCH_NODE=$(kubectl get -n budgetkey pod `get_pod_name budgetkey elasticsearch- | grep -v new` -o yaml | grep nodeName: | cut -d " " -f 4) &&\
ELASTICSEARCH_TARGET_DIR=/budgetkey/elasticsearch &&\
POSTGRES_SOURCE_DIR=/var/lib/kubelet/plugins/kubernetes.io/gce-pd/mounts/budgetkey-postgres-data-2 &&\
POSTGRES_NODE=`get_pod_node_name budgetkey postgres` &&\
POSTGRES_TARGET_DIR=/budgetkey/postgres &&\
ELASTICSEARCH_NEW_SOURCE_DIR=/var/lib/kubelet/plugins/kubernetes.io/gce-pd/mounts/budgetkey-elasticsearch-data-new &&\
ELASTICSEARCH_NEW_NODE=`get_pod_node_name budgetkey elasticsearch-new` &&\
ELASTICSEARCH_NEW_TARGET_DIR=/budgetkey/elasticsearch-new &&\
PIPELINES_SOURCE_DIR=/var/lib/kubelet/plugins/kubernetes.io/gce-pd/mounts/budgetkey-pipelines-data-3 &&\
PIPELINES_NODE=`get_pod_node_name budgetkey pipelines` &&\
PIPELINES_TARGET_DIR=/budgetkey/pipelines
echo $?
```

Verify and check sizes

```
gcloud --project hasadna-general compute ssh $ELASTICSEARCH_NODE -- "sudo df -h $ELASTICSEARCH_SOURCE_DIR" &&\
gcloud --project hasadna-general compute ssh $POSTGRES_NODE -- "sudo df -h $POSTGRES_SOURCE_DIR" &&\
gcloud --project hasadna-general compute ssh $ELASTICSEARCH_NEW_NODE -- "sudo df -h $ELASTICSEARCH_NEW_SOURCE_DIR" &&\
gcloud --project hasadna-general compute ssh $PIPELINES_NODE -- "sudo df -h $PIPELINES_SOURCE_DIR"
```

Migrate

```
export KUBECONFIG=
source switch_environment.sh budgetkey-gke
source functions.sh
TARGET_NFS_IP=194.36.91.251
```

```
mount_nfs_and_rsync ${ELASTICSEARCH_NODE} $TARGET_NFS_IP /media/root${ELASTICSEARCH_SOURCE_DIR}/ \
                    /media/root/var/kamatera-nfs${ELASTICSEARCH_TARGET_DIR}/ \
                    /srv/default2${ELASTICSEARCH_TARGET_DIR}/ &&\
mount_nfs_and_rsync ${POSTGRES_NODE} $TARGET_NFS_IP /media/root${POSTGRES_SOURCE_DIR}/ \
                    /media/root/var/kamatera-nfs${POSTGRES_TARGET_DIR}/ \
                    /srv/default2${POSTGRES_TARGET_DIR}/ &&\
mount_nfs_and_rsync ${ELASTICSEARCH_NEW_NODE} $TARGET_NFS_IP /media/root${ELASTICSEARCH_NEW_SOURCE_DIR}/ \
                    /media/root/var/kamatera-nfs${ELASTICSEARCH_NEW_TARGET_DIR}/ \
                    /srv/default2${ELASTICSEARCH_NEW_TARGET_DIR}/ &&\
mount_nfs_and_rsync ${PIPELINES_NODE} $TARGET_NFS_IP /media/root${PIPELINES_SOURCE_DIR}/ \
                    /media/root/var/kamatera-nfs${PIPELINES_TARGET_DIR}/ \
                    /srv/default2${PIPELINES_TARGET_DIR}/
```

Deploy

```
export KUBECONFIG=/path/to/kamatera/kubeconfig
source switch_environment.sh budgetkey
./helm_upgrade_all.sh
```