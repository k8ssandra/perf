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

# Hardware benchmarks

These should be performed first, without K8ssandra installed.

See [general instructions](./hardware) on hardware benchmarks.

# CQL Benchmarks

These require K8ssandra to be installed.

See [general instructions](./cql) on CQL benchmarks.
