# iDMA BACKEND

This part of the iDMA is responsible for executing 1D transfers.
In the current pulp cluster implementation there are two physical channels:
- One supporting transfers towards L2: *idma_backend_r_obi_rw_init_w_axi*
- The other supporting transfers towards L1: *idma_backend_r_axi_rw_init_rw_obi*

So, the source and destination protocols that are being configured differ from one case to the other.

## Insert Scheme here

### Channel for transfers towards L2
Scheme:
![iDMA_gen_copy_out_backend](../images/iDMA_backend_r_obi_rw_init_w_axi.drawio.svg)

Transportation Layer scheme:
![iDMA_transportation_layer_gen_copy_out](../images/iDMA_transport_layer_r_obi_rw_init_w_axi.drawio.svg)

### Channel for transfers towards L1
Scheme:
![iDMA_gen_copy_in_backend](../images/iDMA_backend_r_axi_rw_init_rw_obi.drawio.svg)

Transportation Layer scheme:
![iDMA_transportation_layer_gen_copy_in](../images/iDMA_transport_layer_r_obi_rw_init_w_axi.drawio.svg)
## Description
