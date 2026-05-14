# Supported software stacks

iDMA is supported both in the pulp-runtime and the pulp-sdk software stacks. At the moment, there are APIs for:
- 1D, 2D, 3D transfers:
    - These functions take care of configuring the iDMA depending on the chosen transfer mode and launching the transfer.
- Individual wait and barrier functions:
    - These functions allow to wait on single transfers (based on its direction), or to wait until no transfers are ongoing in the chosen direction.
- iDMA clock gating control:
    - The clock for iDMA is controlled through the cluster control unit and it can be enabled/disabled through the sw drivers.