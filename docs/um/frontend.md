# iDMA FRONTEND

Structured as follows:
- Register sets
- Some binding logic for requests from the register set to the rest of the iDMA and viceversa
- Round Robin arbiter tree to correctly dispatch the transfers to the required channels

![iDMA Frontend](../images/iDMA_32_3d_frontend.drawio.svg)

## iDMA Register Top

The register set for iDMA is structured as follows:
![iDMA Register Top](../images/iDMA_32_3d_reg_top.drawio.svg)

So, for each master of the iDMA (generally 8 cores + 2 PE), the following are available:
- Configuration registers:
    - These include all the transfer parameters + protocols
- Observational registers:
    - For each physical channel of the iDMA (so 2 in the current iDMA instantiation inside the pulp cluster), a triplet of observational registers is made available. These are necessary for synchronization, arbitrating the transfers and waiting on them.

Register widths:
- CONF_REG: 18-bits wide
- Transfer parameters registers: 32-bits wide
- Observational registers: 10-bits wide
