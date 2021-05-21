#!/bin/bash

set -e

SHARED_DIR=$(cd "$(dirname "$0")" && pwd)
THROUGHPUT_FILE="$SHARED_DIR"/nosqlbench-throughput.yaml
LATENCY_FILE="$SHARED_DIR"/nosqlbench-latency.yaml

K8SSANDRA_USER=$(kubectl get secret k8ssandra-superuser -o jsonpath="{.data.username}" -n k8ssandra | base64 --decode)
K8SSANDRA_PWD=$(kubectl get secret k8ssandra-superuser -o jsonpath="{.data.password}" -n k8ssandra | base64 --decode)

echo
echo Dropping table baselines.tabular...

kubectl exec k8ssandra-dc1-r1-sts-0 -c cassandra -n k8ssandra -- \
  cqlsh -u "$K8SSANDRA_USER" -p "$K8SSANDRA_PWD" \
  --request-timeout="300" \
  -e 'DROP TABLE IF EXISTS baselines.tabular'

echo
echo Starting throughput benchmark...

kubectl create -f "$THROUGHPUT_FILE" -n k8ssandra

THROUGHPUT_JOB_POD=$(kubectl get pods -l job-name=nosqlbench-throughput -n k8ssandra -o jsonpath='{.items[0].metadata.name}')
THROUGHPUT_JOB_NODE=$(kubectl get pod "$THROUGHPUT_JOB_POD" -o jsonpath='{.spec.nodeName}' -n k8ssandra)

echo
echo Benchmark started, waiting until job completes...
echo The job is running on on node "$THROUGHPUT_JOB_NODE": please check that this is correct!
echo You can monitor the job with:
echo kubectl logs job.batch/nosqlbench-throughput -n k8ssandra --follow

kubectl wait --for=condition=complete job.batch/nosqlbench-throughput --timeout=5h -n k8ssandra

echo Throughput benchmark finished.
echo
echo Dropping table baselines.tabular...

kubectl exec k8ssandra-dc1-r1-sts-0 -c cassandra -n k8ssandra -- \
  cqlsh -u "$K8SSANDRA_USER" -p "$K8SSANDRA_PWD" \
  --request-timeout="300" \
  -e 'DROP TABLE IF EXISTS baselines.tabular'

echo
echo Starting latency benchmark...

kubectl create -f "$LATENCY_FILE" -n k8ssandra

LATENCY_JOB_POD=$(kubectl get pods -l job-name=nosqlbench-latency -n k8ssandra -o jsonpath='{.items[0].metadata.name}')
LATENCY_JOB_NODE=$(kubectl get pod "$LATENCY_JOB_POD" -o jsonpath='{.spec.nodeName}' -n k8ssandra)

echo
echo Benchmark started, waiting until job completes...
echo The job is running on on node "$LATENCY_JOB_NODE": please check that this is correct!
echo You can monitor the job with:
echo kubectl logs job.batch/nosqlbench-latency -n k8ssandra --follow

kubectl wait --for=condition=complete job.batch/nosqlbench-latency --timeout=5h  -n k8ssandra

echo Latency benchmark finished.
echo
echo Dropping table baselines.tabular...

kubectl exec k8ssandra-dc1-r1-sts-0 -c cassandra -n k8ssandra -- \
  cqlsh -u "$K8SSANDRA_USER" -p "$K8SSANDRA_PWD" \
  --request-timeout="300" \
  -e 'DROP TABLE IF EXISTS baselines.tabular'

echo
echo Deleting jobs...
kubectl delete -n k8ssandra job.batch/nosqlbench-throughput
kubectl delete -n k8ssandra job.batch/nosqlbench-latency

echo
echo Benchmarks done.
echo Throughput results are available from node "$THROUGHPUT_JOB_NODE" under /tmp/throughput.
echo Latency results are available from node "$LATENCY_JOB_NODE" under /tmp/latency.

