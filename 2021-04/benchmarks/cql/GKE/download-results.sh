#!/bin/bash

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
COUNTER=1
while [ -d "$SCRIPT_DIR/results/run-$(printf "%03d" "$COUNTER")" ]; do
   (( COUNTER+=1 ))
done

RESULTS_DIR="$SCRIPT_DIR/results/run-$(printf "%03d" "$COUNTER")"
mkdir -p "$RESULTS_DIR/throughput"
mkdir -p "$RESULTS_DIR/latency"

echo
echo Results will be saved to "$RESULTS_DIR"

STRESS_NODE=$(kubectl get nodes -o 'jsonpath={.items[0].metadata.name}' -l cloud.google.com/gke-nodepool=stress)
STRESS_ZONE=$(kubectl get node "$STRESS_NODE" -o 'jsonpath={.metadata.labels.topology\.kubernetes\.io/zone}')

echo
echo Dowloading throughput results from "$STRESS_NODE"...

gcloud compute scp "$STRESS_NODE:/tmp/throughput/*.csv" "$RESULTS_DIR/throughput" --zone="$STRESS_ZONE"

echo
echo Dowloading latency results from "$STRESS_NODE"...

gcloud compute scp "$STRESS_NODE:/tmp/latency/*.csv" "$RESULTS_DIR/latency" --zone="$STRESS_ZONE"

echo
echo Results downloaded. Deleting remote files...

gcloud compute ssh "$STRESS_NODE" --zone="$STRESS_ZONE" --command="sudo rm -Rf /tmp/throughput && sudo rm -Rf /tmp/latency"

echo Done.