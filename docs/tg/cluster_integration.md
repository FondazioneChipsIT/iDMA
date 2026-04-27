# Integration in Pulp Cluster

Currently, the iDMA is instantiated within the pulp cluster as follows:

- 10 Master Ports:
    - 8 Cores
    - 2 PE
- 1 Bidirectional Stream:
    - This is to be intended as two physical channels that can work in parallel towards L1 and towards L2.
- Fifo Depth set to 8:
    - This means that up to 8 transfer configurations can be saved for each direction --> 16 total transfers can be configured into the iDMA at the same time.

## Pulp Cluster integration scheme:

![iDMA Cluster Integration](../images/iDMA_Cluster_integration.drawio.svg)