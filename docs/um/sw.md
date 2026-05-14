# Supported SW Stacks

Currently, iDMA is supported in the pulp-sdk and pulp-runtime software stacks. The following are provided:
- Transfer functions
    - These allow to configure and execute multi-dimensional transfers (from 1D to 3D).
- Synchronization functions
    - Both individual wait and barrier functions are provided. Individual wait functions allow to wait on specific transfers once their id is provided, whereas barriers allow to wait until no transfers are ongoing on the specified direction.
- Clock gating control
    - The sw-controlled clock (configured into the cluster control unit) can be enabled/disabled through the sw drivers.

So, the usual call to iDMA looks like this:
- Enable the sw-controlled clock
- Transfer configuration:
    - Provide the needed parameters for a transfer to be executed correctly, meaning:
        - Addresses: starting addresses for both the source and the destination memory regions
        - Transfer size: specify the size of the transfer in bytes (up to 65535)
        - Dimensional parameters: specify the strides (both at the source and the destination) and the length parameters.
    - Transfer execution: handled inside the transfer function.
- Synchronization: 
    - Depending on the user needs, choose whether to wait for the individual transfer or until no transfers are ongoing on a certain direction.
- Disable the sw-controlled clock