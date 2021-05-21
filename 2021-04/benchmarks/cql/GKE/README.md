# Running the CQL benchmarks on GKE

Note: Installing K8ssandra requires Helm. On MacOS:

    brew install helm

Testing is done with dynamic volume provisioning and standard-rwo storage class, which is the
recommended storage setup.

Relevant reading: [Dynamic Volume
Provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/).

To test using the recommended standard-rwo storage class, execute the [install-k8ssandra](
./shared/install-k8ssandra.sh) and the [run-benchmarks](../shared/run-cql-benchmarks.sh) scripts
with the following arguments:

    ../shared/install-k8ssandra.sh standard-rwo us-central1-a us-central1-b us-central1-c
    ../shared/run-cql-benchmarks.sh 

You can also test the premium-rwo storage class:

    ../shared/install-k8ssandra.sh premium-rwo us-central1-a us-central1-b us-central1-c
    ../shared/run-cql-benchmarks.sh 

# Monitoring the tests

The test logs are accessible with the following commands:

    kubectl logs job.batch/nosqlbench-throughput --follow
    kubectl logs job.batch/nosqlbench-latency --follow

# Getting the test results

Run the [results](download-results.sh) script:

    ./results.sh

Results will be downloaded from the stress node to two local folders:

* `./results/run-001/throughput`
* `./results/run-001/latency`