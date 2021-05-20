#!/bin/bash

CURRENT_DIR=$(cd "$(dirname "$0")" && pwd)

echo
echo Creating persistent volumes with local-storage class...

kubectl create -f "$CURRENT_DIR"/local-pv1.yaml
kubectl create -f "$CURRENT_DIR"/local-pv2.yaml
kubectl create -f "$CURRENT_DIR"/local-pv3.yaml

NODES=$(kubectl get nodes \
  -o 'jsonpath={range .items[*]}{.metadata.name}{" "}{end}' \
  -l cloud.google.com/gke-nodepool=default-pool)

for node in $NODES
do
    zone=$(kubectl get node "$node" -o 'jsonpath={.metadata.labels.topology\.kubernetes\.io/zone}')
    echo
    echo Creating mount point /var/lib/cassandra on node "$node" in zone "$zone"...
    gcloud compute ssh "$node" --zone="$zone" --command="sudo mkdir -p /var/lib/cassandra && sudo chmod 777 /var/lib/cassandra"
done

echo
echo Persistent volumes and mount points successfully created.

#kubectl get nodes \
#  -o 'jsonpath={range .items[*]}{.metadata.name} --zone={.metadata.labels.topology\.kubernetes\.io/zone}{"\n"}{end}' \
#  -l cloud.google.com/gke-nodepool=default-pool | \
#  xargs -I % sh -c 'gcloud compute ssh % --command="sudo mkdir -p /var/lib/cassandra && sudo chmod 777 /var/lib/cassandra"'