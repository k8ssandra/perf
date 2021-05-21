#!/bin/bash

set -e

CURRENT_DIR=$(cd "$(dirname "$0")" && pwd)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

ROOT_DIR="$CURRENT_DIR"/results/"$TIMESTAMP"
THROUGHPUT_DIR="$ROOT_DIR"/throughput
LATENCY_DIR="$ROOT_DIR"/latency

STRESS_NODE=$(kubectl get nodes -o 'jsonpath={.items[0].metadata.name}' -l cloud.google.com/gke-nodepool=stress)
STRESS_ZONE=$(kubectl get node "$STRESS_NODE" -o 'jsonpath={.metadata.labels.topology\.kubernetes\.io/zone}')

echo
echo Saving results to "$ROOT_DIR"...

mkdir -p "$ROOT_DIR"/throughput
mkdir -p "$ROOT_DIR"/latency

echo
echo Dowloading throughput results from "$STRESS_NODE"...

gcloud compute scp "$STRESS_NODE:/tmp/throughput/*.csv" "$THROUGHPUT_DIR" --zone="$STRESS_ZONE"

echo
echo Dowloading latency results from "$STRESS_NODE"...

gcloud compute scp "$STRESS_NODE:/tmp/latency/*.csv" "$LATENCY_DIR" --zone="$STRESS_ZONE"

echo
echo Results downloaded. Deleting remote files...

gcloud compute ssh "$STRESS_NODE" --zone="$STRESS_ZONE" --command="sudo rm -Rf /tmp/throughput && sudo rm -Rf /tmp/latency"

echo Done.