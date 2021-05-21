#!/bin/bash

if [ $# -ne 1 ]; then
  echo Usage:
  echo "run-disk-benchmarks <storage-class>"
  exit 1
else
  STORAGE_CLASS=$1
fi

SHARED_DIR=$(cd "$(dirname "$0")" && pwd)
COUNTER=1
while [ -d "$SHARED_DIR/results/disk/$STORAGE_CLASS/run-$(printf "%03d" "$COUNTER")" ]; do
   (( COUNTER+=1 ))
done

RESULTS_DIR="$SHARED_DIR/results/disk/$STORAGE_CLASS/run-$(printf "%03d" "$COUNTER")"
mkdir -p "$RESULTS_DIR"

echo
echo Results will be saved to "$RESULTS_DIR"

echo
echo Creating PVC fio-bench-claim-"$STORAGE_CLASS"...

cat << EOF | kubectl create -n k8ssandra -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fio-bench-claim-$STORAGE_CLASS
  namespace: k8ssandra
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 2Ti
  storageClassName: $STORAGE_CLASS
EOF

echo
echo Creating Pod fio-bench-pod-"$STORAGE_CLASS"...

cat << EOF | kubectl create -n k8ssandra -f -
apiVersion: v1
kind: Pod
metadata:
  name: fio-bench-pod-$STORAGE_CLASS
  namespace: k8ssandra
spec:
  containers:
    - args:
        - sleep
        - "36000"
      image: ubuntu:focal
      name: fio-bench-pod-$STORAGE_CLASS
      resources:
        requests:
          memory: 55Gi
          cpu: 7200m
      volumeMounts:
        - mountPath: "/var/lib/cassandra/fio"
          name: fio
  volumes:
    - name: fio
      persistentVolumeClaim:
        claimName: fio-bench-claim-$STORAGE_CLASS
  dnsPolicy: ClusterFirst
  restartPolicy: Always
EOF

set -e

echo
echo Waiting for pod fio-bench-pod-"$STORAGE_CLASS" to become ready...

kubectl wait --for=condition=ready pod/fio-bench-pod-"$STORAGE_CLASS" -n k8ssandra

NODE=$(kubectl get pod fio-bench-pod-"$STORAGE_CLASS" -o jsonpath='{.spec.nodeName}' -n k8ssandra)

echo Pod fio-bench-pod-"$STORAGE_CLASS" is running on node "$NODE": please check that this is correct!

echo
echo Installing FIO...

kubectl exec -it pod/fio-bench-pod-"$STORAGE_CLASS" -n k8ssandra -- bash -c \
  'apt-get update -y &&
   apt-get install -y fio'

echo
echo Copying the benchmark definitions...

kubectl cp "$SHARED_DIR"/cassandra-fio.tar.gz k8ssandra/fio-bench-pod-"$STORAGE_CLASS":/tmp

kubectl exec -it pod/fio-bench-pod-"$STORAGE_CLASS"  -n k8ssandra -- \
  bash -c 'rm -Rf /tmp/cassandra-fio && mkdir -p /tmp/cassandra-fio && tar xzf /tmp/cassandra-fio.tar.gz -C /tmp'

echo
echo Running the benchmarks...

kubectl exec -it pod/fio-bench-pod-"$STORAGE_CLASS" -n k8ssandra -- \
  bash -c '(cd /tmp/cassandra-fio/; sh ./fio_runner.sh all)'

echo
echo Downloading results...

kubectl cp k8ssandra/fio-bench-pod-"$STORAGE_CLASS":/tmp/cassandra-fio/reports "$RESULTS_DIR"

echo
echo Deleting pod and PVC...

kubectl delete pod/fio-bench-pod-"$STORAGE_CLASS" -n k8ssandra
kubectl delete persistentvolumeclaim/fio-bench-claim-"$STORAGE_CLASS" -n k8ssandra

echo
echo Benchmarks done.