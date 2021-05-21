# Infrastructure setup

Setting up the infrastructure is largely vendor-dependent, but the setup must conform to a few
requirements:

* The Cassandra cluster must have 3 nodes;
* Each node must have at least 55Gi memory and 7100 mCPUs; ideally 61Gi and 7500.
* No Stargate, Reaper, nor Medusa installed.
* CQL benchmarks must be performed on a separate node with 8Gi memory and 7500 mCPUs. The client
  process must not be collocated on a node running Cassandra.
  
Vendor-specific instructions:

* baseline: [general instructions](./baseline/) on baseline infrastructure setup.
* GKE: [general instructions](./GKE/) on GKE infrastructure setup.
