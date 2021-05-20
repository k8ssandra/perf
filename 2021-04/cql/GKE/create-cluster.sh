#!/bin/bash

gcloud container clusters create "k8ssandra-perf" \
  --cluster-version "1.19.9-gke.1400" \
  --release-channel "regular" \
  --machine-type "n2-highmem-8" \
  --image-type "UBUNTU_CONTAINERD" \
  --zone "us-central1-a" \
  --node-locations "us-central1-a,us-central1-b,us-central1-c" \
  --num-nodes "1" \
  --disk-type "pd-ssd" \
  --disk-size "100" \
  --local-ssd-count "8"

# Notes:
# `--disk-type` and `--disk-size` govern the boot disk characteristics.
# `--local-ssd-count` governs the amount of attached SSD local drives – this is required for testing
#  with local persistent volumes.

gcloud container node-pools create "stress" \
  --cluster "k8ssandra-perf" \
  --node-version "1.19.9-gke.1400" \
  --machine-type "n2-highcpu-16" \
  --image-type "COS_CONTAINERD" \
  --zone "us-central1-a" \
  --node-locations "us-central1-a" \
  --num-nodes "1" \
  --disk-type "pd-ssd" \
  --disk-size "100"

gcloud container clusters get-credentials k8ssandra-perf --zone us-central1-a

echo
echo Successfully created cluster and node pools.

echo
echo Cluster info:
gcloud container clusters list --filter k8ssandra-perf

echo
echo Node pools info:
gcloud container node-pools list --cluster k8ssandra-perf