#!/bin/bash

mkdir ./results

STRESS_NODE=$(kubectl get nodes -o 'jsonpath={.items[0].metadata.name}' -l cloud.google.com/gke-nodepool=stress)

gcloud compute scp "$STRESS_NODE":/tmp/throughput/cqltabular2_default_main.cycles.servicetime.csv ./results/throughput.csv

gcloud compute scp "$STRESS_NODE":/tmp/latency/cqltabular2_default_main.cycles.servicetime.csv ./results/latency.csv
