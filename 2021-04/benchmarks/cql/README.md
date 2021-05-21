# Running CQL benchmarks

Two `nosqlbench` tests will be executed on each benchmarked Cloud vendor: the first focuses on
throughput, the second on latency.

On the baseline setup, the benchmarks need to be manually launched.

For Kubernetes cloud providers: the benchmarks can be executed on a running Kubernetes cluster with
K8ssandra previously installed, by simply running the following shared script:

    ./shared/run-cql-benchmarks.sh

Unfortunately, it's not possible to download the benchmark results in a vendor-agnostic way, so each
vendor will have its own method for downloading them:

* [EKS](./EKS)
* [GKE](GKE)
* [AKS](./AKS)

# Benchmark characteristics

Throughput benchmark characteristics:

* No rate limiting with 100M cycles and up to 300 in flight async queries, 50% writes and 50% reads
at `LOCAL_QUORUM`, using the `cql-tabular2` profile with partitions of 5k rows.

See YAML Job definition [here](shared/nosqlbench-throughput.yaml).

Latency benchmark characteristics:

* Rate limited at 8k ops/s with 50M cycles and up to 300 in flight async queries, 50% writes and 50%
reads at `LOCAL_QUORUM`, using the `cql-tabular2` profile with partitions of 5k rows.

See YAML Job definition [here](shared/nosqlbench-latency.yaml).

