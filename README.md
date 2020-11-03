# EMBA
This tool is developed based on an Intel open-source project PQoS (https://github.com/intel/intel-cmt-cat/pqos).

EMBA takes advantage of Intel MBA (memory bandwidth allocation) technology to dynamically improve performance.

Detailed methodology and evaluation can be found in this paper:

[*EMBA: Efficient Memory Bandwidth Allocation to Improve Performance on Intel Commodity Processor.*](https://dl.acm.org/citation.cfm?doid=3337821.3337863)

## Requirement
EMBA has the following requirements:

1. Target system must be equipped with the Intel MBA, e.g. Intel(R) Xeon(R) Scalable Processors.

2. Memory bandwidth must be saturated. If the workloads in system consume little available memory bandwidth, bandwidth throttling may cause performance degradation. Our results show when the ratio of _**#physical cores**_ to _**#memory channel**_ is not less than 4, EMBA can improve performance efficiently. Otherwise, in terms of batch throughput, memory bandwidth contention may be negligible and it is hard to improve performance via Intel MBA.

3. Linux kernel version 4.12 and newer.

## Usage
* Step 1: Build
```
make
```
* Step 2: Run EMBA
```
./emba
```
