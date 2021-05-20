#!/bin/bash

if [ $# -ne 4 ]; then
  echo Usage:
  echo "install-k8ssandra.sh <storage-class> <rack1-zone> <rack2-zone> <rack3-zone>"
  exit 1
else
  STORAGE_CLASS=$1
  RACK1_ZONE=$2
  RACK2_ZONE=$3
  RACK3_ZONE=$4
fi

SHARED_DIR=$(cd "$(dirname "$0")" && pwd)
HELM_FILE="$SHARED_DIR"/k8ssandra-perf.yaml

kubectl create namespace k8ssandra

helm repo add k8ssandra https://helm.k8ssandra.io/stable

helm repo update

helm install k8ssandra k8ssandra/k8ssandra -n k8ssandra -f "$HELM_FILE" \
   --set "cassandra.cassandraLibDirVolume.storageClass=$STORAGE_CLASS" \
   --set "cassandra.datacenters[0].racks[0].affinityLabels.topology\.kubernetes\.io/zone=$RACK1_ZONE" \
   --set "cassandra.datacenters[0].racks[1].affinityLabels.topology\.kubernetes\.io/zone=$RACK2_ZONE" \
   --set "cassandra.datacenters[0].racks[2].affinityLabels.topology\.kubernetes\.io/zone=$RACK3_ZONE"
