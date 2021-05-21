#!/bin/bash

SHARED_DIR=$(cd "$(dirname "$0")" && pwd)

COUNTER=1
while [ -d "$SHARED_DIR/results/cpu/run-$(printf "%03d" "$COUNTER")" ]; do
   (( COUNTER+=1 ))
done

RESULTS_DIR="$SHARED_DIR/results/cpu/run-$(printf "%03d" "$COUNTER")"
mkdir -p "$RESULTS_DIR"

echo
echo Results will be saved to "$RESULTS_DIR"

echo
echo Creating Pod sysbench-pod...

cat << EOF | kubectl create -n k8ssandra -f -
apiVersion: v1
kind: Pod
metadata:
  name: sysbench-pod
  namespace: k8ssandra
spec:
  containers:
    - args:
        - sleep
        - "36000"
      image: ubuntu:focal
      name: sysbench-pod
      resources:
        requests:
          memory: 55Gi
          cpu: 7200m
  dnsPolicy: ClusterFirst
  restartPolicy: Always
EOF

set -e

echo
echo Waiting for pod sysbench-pod to become ready...

kubectl wait --for=condition=ready pod/sysbench-pod -n k8ssandra

NODE=$(kubectl get pod sysbench-pod -o jsonpath='{.spec.nodeName}' -n k8ssandra)

echo Pod sysbench-pod is running on node "$NODE": please check that this is correct!

echo
echo Installing sysbench...

kubectl exec -it pod/sysbench-pod -n k8ssandra -- bash \
  -c 'apt-get update &&
      apt-get install -y curl &&
      curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | bash &&
      apt-get install -y sysbench'

echo
echo Running the benchmarks...

kubectl exec -it pod/sysbench-pod -n k8ssandra -- \
  bash -c 'sysbench cpu --threads=8 --time=120 run' >> "$RESULTS_DIR"/sysbench.out

echo
echo Deleting pod...

kubectl delete pod/sysbench-pod -n k8ssandra

echo
echo Benchmarks done.