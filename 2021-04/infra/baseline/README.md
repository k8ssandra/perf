# Baseline Infrastructure Setup

Baseline benchmarks will be conducted on AWS.

### Cassandra nodes
* Cassandra nodes: 3
* Cassandra instance type: i3.2xlarge - 8 vCPU / 61GB RAM / 1.7TB NVMe SSD
* Instance type: r5.2xlarge
* Volume size: 3TB

### Stress nodes
* Stress nodes: 1
* Stress instance type: c5.2xlarge - 8 vCPU / 15GB RAM

### Stargate nodes
* Stargate nodes: 0

### Monitoring nodes
* Monitoring node: 1

JVM flags:

    -XX:+UseG1GC
    -XX:G1RSetUpdatingPauseTimePercent=5
    -XX:MaxGCPauseMillis=300
    -XX:InitiatingHeapOccupancyPercent=70
    -Xms31G
    -Xmx31G
