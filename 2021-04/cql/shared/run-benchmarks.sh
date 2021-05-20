#!/bin/bash

SHARED_DIR=$(cd "$(dirname "$0")" && pwd)
THROUGHPUT_FILE="$SHARED_DIR"/nosqlbench-throughput.yaml
LATENCY_FILE="$SHARED_DIR"/nosqlbench-latency.yaml

K8SSANDRA_USER=$(kubectl get secret k8ssandra-superuser -o jsonpath="{.data.username}" -n k8ssandra | base64 --decode)
K8SSANDRA_PWD=$(kubectl get secret k8ssandra-superuser -o jsonpath="{.data.password}" -n k8ssandra | base64 --decode)

echo
echo Truncating baselines.tabular...

kubectl exec k8ssandra-dc1-r1-sts-0 -c cassandra -n k8ssandra -- \
  cqlsh -u "$K8SSANDRA_USER" -p "$K8SSANDRA_PWD" \
  -e 'DROP TABLE IF EXISTS baselines.tabular'

echo
echo Starting throughput benchmark...

kubectl create -f "$THROUGHPUT_FILE" -n k8ssandra

echo
echo Benchmark started, waiting until job completes...
echo You can monitor the job with:
echo kubectl logs job.batch/nosqlbench-throughput -n k8ssandra --follow

kubectl wait --for=condition=complete job.batch/nosqlbench-throughput --timeout=5h

echo Throughput benchmark finished.
echo
echo Truncating baselines.tabular...

kubectl exec k8ssandra-dc1-r1-sts-0 -c cassandra -n k8ssandra -- \
  cqlsh -u "$K8SSANDRA_USER" -p "$K8SSANDRA_PWD" \
  -e 'TRUNCATE baselines.tabular'

echo
echo Starting latency benchmark...

kubectl create -f "$LATENCY_FILE" -n k8ssandra

echo
echo Benchmark started, waiting until job completes...
echo You can monitor the job with:
echo kubectl logs job.batch/nosqlbench-latency -n k8ssandra --follow

kubectl wait --for=condition=complete job.batch/nosqlbench-latency --timeout=5h

echo Latency benchmark finished.
echo
echo Truncating baselines.tabular...

kubectl exec k8ssandra-dc1-r1-sts-0 -c cassandra -n k8ssandra -- \
  cqlsh -u "$K8SSANDRA_USER" -p "$K8SSANDRA_PWD" \
  -e 'TRUNCATE baselines.tabular'

echo
echo Benchmarks done.