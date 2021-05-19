# Overview 

Hardware benchmarks should be performed directly on a machine having the exact instance type and
characteristics that were used for the CQL benchmarks.

## Hardware CPU benchmark

Install `sysbench` by running the following commands on one of the worker node by SSHing directly on
it:

Ubuntu/Debian:

    curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
    sudo apt -y install sysbench

RHEL/CentOS:

    curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
    sudo yum -y install sysbench

Run the CPU benchmark using:

    sysbench cpu --threads=8 --time=120 run

Paste the results in the “Config” sheet of the K8ssandra I/O intensive spreadsheet.

## Hardware I/O benchmark

Install `fio` by running the following commands on one of the worker node by SSHing directly on it:

Ubuntu:

    sudo apt install fio

RHEL/Centos:

    sudo yum install fio

Upload and decompress the following tarball on the worker node: cassandra-fio.tar.gz

By default, the benchmarks will run against `/var/lib/cassandra/fio` and you may need to edit the
`fio_runner.sh` file along with the *.fio files if your persistent volumes are using a different host
path.

Run the following command to perform the I/O benchmarks:

    ./fio_runner.sh

Extract the following blocks from the reports/*.out files into the corresponding cells in the
spreadsheet:

    stcs_32k_write: (groupid=1, jobs=1): err= 0: pid=451: Wed Apr 28 16:15:05 2021
    write: IOPS=3487, BW=109MiB/s (114MB/s)(6540MiB/60003msec)
    slat (usec): min=3, max=1905, avg= 7.87, stdev= 4.72
    clat (usec): min=608, max=45209, avg=2283.97, stdev=862.14
    lat (usec): min=617, max=45218, avg=2292.08, stdev=862.10
    clat percentiles (usec):
    |  1.00th=[ 1057],  5.00th=[ 1549], 10.00th=[ 1745], 20.00th=[ 1926],
    | 30.00th=[ 2057], 40.00th=[ 2147], 50.00th=[ 2245], 60.00th=[ 2311],
    | 70.00th=[ 2409], 80.00th=[ 2507], 90.00th=[ 2704], 95.00th=[ 2900],
    | 99.00th=[ 4555], 99.50th=[ 7701], 99.90th=[12911], 99.95th=[14484],
    | 99.99th=[23987]
    
    stcs_32k_read: (groupid=1, jobs=1): err= 0: pid=452: Wed Apr 28 16:15:05 2021
    read: IOPS=4516, BW=141MiB/s (148MB/s)(8469MiB/60003msec)
    slat (nsec): min=2703, max=40242, avg=5527.56, stdev=2247.76
    clat (usec): min=248, max=94623, avg=1762.19, stdev=1313.96
    lat (usec): min=254, max=94627, avg=1767.94, stdev=1313.83
    clat percentiles (usec):
    |  1.00th=[  469],  5.00th=[  791], 10.00th=[  906], 20.00th=[ 1057],
    | 30.00th=[ 1385], 40.00th=[ 1680], 50.00th=[ 1827], 60.00th=[ 1926],
    | 70.00th=[ 1991], 80.00th=[ 2089], 90.00th=[ 2278], 95.00th=[ 2540],
    | 99.00th=[ 4228], 99.50th=[ 6849], 99.90th=[19268], 99.95th=[26870],
    | 99.99th=[43254]
