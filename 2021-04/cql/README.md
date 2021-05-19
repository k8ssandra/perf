# Test Profiles

Two `nosqlbench` workloads will be executed on each benchmarked Cloud vendor: the first focuses on
throughput, the second on latency.

## Throughput test profile

No rate limiting with 100M cycles and up to 300 in flight async queries, 50% writes and 50% reads at
`LOCAL_QUORUM`, using the `cql-tabular2` profile with partitions of 5k rows.

See YAML Job definition [here](./nosqlbench/throughput.yaml).

## Latency test profile

Rate limited at 8k ops/s with 50M cycles and up to 300 in flight async queries, 50% writes and 50%
reads at `LOCAL_QUORUM`, using the `cql-tabular2` profile with partitions of 5k rows.

See YAML Job definition [here](./nosqlbench/latency.yaml).

# Benchmarks per Cloud vendor

See specific instructions for each Cloud vendor:

* [Baseline](./baseline)
* [EKS](./EKS)
* [GKE](./GKE)
* [AKS](./AKS)