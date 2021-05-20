# Infrastructure Setup

Three different instance types were benchmarked:

* Commodity: e2-highmem-8
* Recommended: n2-highmem-8
* High performance: c2-highmem-16

Benchmarks showed poor throughput and latency for e2-highmem-8. n2-highmem-8 and c2-highmem-16 both
use Cascade Lake processors and show good overall results. 

_We recommend n2-highmem-8 as a good starting point._

# Pre-install steps

## Install `gcloud`

Google Cloud SDK on macOS can be installed with brew:

    brew install --cask google-cloud-sdk

## Set up `kubectl`

For general information on how to use `kubectl` with GKE, read
[this](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl).

In order to be able to create Kubernetes clusters on GKE and run the benchmarks, you need to have
credentials with the following roles granted:

* Kubernetes Engine Admin
* Kubernetes Engine Cluster Admin

See [role based access
control](https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control) for more.

Run on your local machine:

    gcloud init

## Creating the cluster

### Using `gcloud`

Run the [create-cluster](./create-cluster.sh) script:

    ./create-cluster.sh

### Using the GKE console

On the GKE console, create a Classic Kubernetes cluster (no Autopilot).

#### Cluster basics

* name: `k8ssandra-perf`
* location type: zonal
* Control Plane zone: us-central1-a
* k8s release channel: regular
* k8s version: 1.19.9-gke.1400 

#### Node pools

* Main node pool: `default-pool`
  * Number of nodes per zone: 1 (no autoscaling) (=3 total)
  * Zones: us-central1-a, us-central1-b, us-central1-c
  * Image type:  Ubuntu with containerd  
  * Machine type: choose between the following, see above for explanations:
    * e2-highmem-8 (8 vCPU, 64 GB memory)
    * n2-highmem-8 (8 vCPU, 64 GB memory) (RECOMMENDED)
    * c2-highmem-16 (16 vCPU, 64 GB memory)
  * Disk type: SSD persistent disk
  * Disk size: 100 GB
  * Local SSD disks (per node): 8 (required for testing with local persistent volumes)
  * Networking: defaults (public cluster)
  * Security: defaults

* Stress node pool: `stress`
  * Number of nodes: 1 (no autoscaling)
  * Zones: us-central1-a
  * Image type:  Container-Optimized OS with Containerd (cos_containerd)  
  * Machine type:  n2-highcpu-16 (16 vCPU, 16 GB memory)
  * Disk type: SSD persistent disk
  * Disk size: 100 GB
  * Security: default values
  * Networking: defaults (public cluster)
  * Security: defaults

## Post-creation steps

Set up `kubectl` to connect to your newly-created GKE cluster (this is already done by the
create-cluster script, you only need to do this manually if you used the GKE console to create the
cluster):

    gcloud container clusters get-credentials k8ssandra-perf --zone us-central1-a

# Running the tests

Note: Installing K8ssandra requires Helm. On MacOS:

    brew install helm

## Testing with dynamic volume provisioning

This is the recommended volume setup.

Relevant reading: [Dynamic Volume
Provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/).

To test using the recommended standard-rwo storage class, execute the [install-k8ssandra](
../shared/install-k8ssandra.sh) and the [run-benchmarks](../shared/run-benchmarks.sh) scripts with
the following arguments:

    ../shared/install-k8ssandra.sh standard-rwo us-central1-a us-central1-b us-central1-c
    ../shared/run-benchmarks.sh 

You can also test the premium-rwo storage class:

    ../shared/install-k8ssandra.sh premium-rwo us-central1-a us-central1-b us-central1-c
    ../shared/run-benchmarks.sh 

## Testing with local persistent volumes

Relevant readings: 

* [GCP docs on Local Persistent
Volumes](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/local-ssd).
* [GCP docs on local SSDs](https://cloud.google.com/compute/docs/disks/local-ssd#create_local_ssd).
* [K8s docs on Local Persistent Volumes](https://kubernetes.io/docs/concepts/storage/volumes/#local).

Local volumes can only be used as a statically created PersistentVolume. Dynamic provisioning is not
supported.

Also, local SSD storage is not available for all instance types, see [machine type
restrictions](https://cloud.google.com/compute/docs/disks#local_ssd_machine_type_restrictions).

The benchmarks were done using manually-created local persistent-volumes, as described
[here](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/local-ssd#example_local_pvs).

To run the benchmarks using local storage, execute the following commands:

    ./create-pvs.sh
    ../shared/install-k8ssandra.sh local-storage us-central1-a us-central1-b us-central1-c
    ../shared/run-benchmarks.sh 

# Monitoring the tests

The test logs are accessible with the following commands:

    kubectl logs job.batch/nosqlbench-throughput --follow
    kubectl logs job.batch/nosqlbench-latency --follow

# Getting the test results

TODO