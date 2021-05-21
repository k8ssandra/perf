# Overview 

Hardware benchmarks should be performed directly on a pod running on the same instance type that is
going to be used for Cassandra nodes in the CQL benchmarks.

The hardware benchmarks must be conducted when K8ssandra is not installed, otherwise pods might fail
to be scheduled.

## Hardware CPU benchmark

CPU benchmarks use sysbench.

Execute the [run-cpu-benchmarks](shared/run-cpu-benchmarks.sh) script:

    ./shared/run-cpu-benchmarks.sh

Results will be stored under `./results/cpu`.

## Hardware disk benchmark

Disk benchmarks use FIO with custom tests tailored for Cassandra; they also target a specific
storage class.

Execute the [run-disk-benchmarks](shared/run-disk-benchmarks.sh) script and pass the desired
storage class as an argument, for example:

    ./shared/run-disk-benchmarks.sh my-storage-class

Results for the above example will be stored under `./results/disk/my-storage-class`.
