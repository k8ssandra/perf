# Overview

K8ssandra will be benchmarked on the biggest cloud vendors managed Kubernetes services: AWS EKS, GCP
GKE and Azure AKS.

The following benchmarks will be carried over:

1. Hardware benchmarks. In order to understand performance differences we first need to benchmark
the hardware on which the pods get scheduled. We’ll benchmark raw CPU performance using `sysbench`
and I/O performance using `fio`.
   
2. CQL benchmarks. The benchmarks will be conducted with `nosqlbench` using the `cql-tabular2`
profile, comparing the results of each cloud vendor against a baseline reference using AWS EC2
instances.

# Setting up the infrastructure

See
# Running the benchmarks

Hardware benchmarks should be performed first, without K8ssandra installed. See [general
instructions](benchmarks/hardware) on hardware benchmarks.

CQL benchmarks should be performed after, as they require K8ssandra to be installed. 

There is a shared script [here](./infra/shared/install-k8ssandra.sh) that installs K8ssandra on a
running Kubernetes cluster. The script expects 4 arguments: the storage class to use, and 3 zone
names where the 3 Cassandra nodes should be created.

See [general instructions](benchmarks/cql) on CQL benchmarks.
