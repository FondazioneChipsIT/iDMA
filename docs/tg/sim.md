# Software stacks

Currently, iDMA simulation is supported both in the pulp-sdk and the pulp-runtime. Besides minimal differences, the main supported features are:

- Supported directions: L1->L2, L1->L2, L1-L1
- On each direction, transfers up to 3 dimensions and 64 kByte of total size can be configured.
- Both individual wait and barrier functions based on the transfer direction are supported.

On both sw stacks, the following testcases are supported:

- Transfer dimensions: 1D, 2D and 3D.
- Multi-core modes: all 8 cores can program the iDMA. Depending on whether MULTI_CORE_S or MULTI_CORE_P is enabled, this happens in a serial or parallel way.
- All transfer directions are tested.
- Stimuli for each transfer are generated through python scripts, meaning:

    - 1D Transfers: size, src_addr, dst_addr
    - 2D Transfers: size, src_addr, dst_addr, src_stride, dst_stride
    - 3D Transfers: size, src_addr, dst_addr, src_stride, dst_stride, src_stride_3d, dst_stride_3d, number of 3d repetitions

**TODO**: allow for burst length configurability directly from the drivers.

iDMA tests in regression tests repository: https://github.com/FondazioneChipsIT/regression_tests/tree/new_iDMA_tests/idma_tests

Inside the regression tests folder there is also a benchmark test, that's being used for power evaluations. This test allows three modes:+ù

    - TX: allows to enqueue up to 8 transfers towards L2
    - RX: allows to enqueue up to 8 transfers towards L1
    - TX_RX: allows to enqueue up to 8 transfers for each direction and executes them 2-by-2 in parallel.
    - IDLE: the iDMA does nothing and a transfer is executed by Core 0.

iDMA tests in pulp-sdk repository: https://github.com/FondazioneChipsIT/pulp-sdk/tree/chips-it/tests/idma

# Deeploy support

iDMA is partially supported inside Deeploy as well (only 1D transfers for now). Can be found here: https://github.com/FondazioneChipsIT/Deeploy/commits/chips-it/

At the moment, only simulation on the pulp-open + iDMA rtl platform is supported (gvsoc model needs to be updated).