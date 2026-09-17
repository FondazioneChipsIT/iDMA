# Getting started on iDMA

iDMA can be cloned as a Bender dependency from one of the supported platforms. The most tested until now are:

- [pulp-open](https://github.com/FondazioneChipsIT/pulp) 
- [pulp-cluster](https://github.com/FondazioneChipsIT/pulp_cluster)

Cloning the IP is not enough, almost all of iDMA rtl code needs to be generated. So, the following rule needs to be called in order to successfully compile the IP:

```Makefile
venv:
    python3 -m venv $(VENV) && \
    $(VENV)/bin/python -m pip install -U pip && \
    $(VENV)/bin/python -m pip install -r $(shell bender path idma)/requirements.txt

generate_idma_rtl: venv
    . "$(VENV)/bin/activate" && $(MAKE) -C $(shell bender path idma) idma_hw_all
```

## Note

A python environment is strongly encouraged as a mean to successfully generate the rtl for this IP. The **venv** rule is there to ensure this is the case.

This makes sure that all the needed System Verilog files are generated into the target/rtl folder.

## Dependencies

iDMA itself has some hw dependencies, such as:

```yaml
dependencies:
  axi
  axi_stream
  common_cells
  common_verification
  register_interface
  obi
```

## Building supported RTL plaforms

As mentioned, iDMA RTL code needs to be generated before compiling the chosen rtl platform.

### Pulp cluster

The current flow for building the RTL pulp cluster platform is the following:

```bash
make init ## Bender clone and checkout + iDMA rtl generation + compile.tcl script creation
make build ## This compiles the RTL platform based on the compile.tcl generated script

```

### Pulp-open

```bash
make init ## Bender clone and checkout + iDMA rtl generation + compile.tcl script creation
make build ## This compiles the RTL platform based on the compile.tcl generated script

```

## Building and simulating iDMA in Pulp-SDK and Pulp-runtime

Once the RTL platform has been successfully populated with IPs and compiled, iDMA can be tested at system level within the following software stacks:

- [pulp-runtime](https://github.com/FondazioneChipsIT/pulp-runtime): note that only pulp cluster is currently supported on this software stack
- [pulp-sdk](https://github.com/FondazioneChipsIT/pulp-sdk): not that only pulp-open is currently supported on this software stack

Depending on the chosen RTL platform follow one of the listed flows.

### Pulp-runtime flow

Clone the software stack [here](https://github.com/FondazioneChipsIT/pulp-runtime)
Clone the tests [here](https://github.com/FondazioneChipsIT/regression_tests).
Then:

``` bash
# From the top pulp_cluster dir

# Setup the toolchain, on Chips-IT machines the following is true:

export PULP_RISCV_GCC_TOOLCHAIN=/opt/riscv/pulp-gcc-1.0.16/
source scripts/vsim.sh # This sets the needed VSIM_PATH env variable

source pulp-runtime/configs/pulp_cluster.sh # This sets the environment for pulp cluster simulation

cd regression_tests/idma_tests/idma_multi_core # Move to the tests directories
make clean all run # Compile and execute the test in console mode
```

This sequence of commands executes a basic 1D iDMA test. Some flags can be added:

- gui=1: this opens the Modelsim graphical user interface
- VERBOSE=1: this enables the debug printfs inside the test (disabled by default)
- MULTI_CORE_S=1: this enables the serial multi-core execution, meaning the iDMA is used by all the cores in the cluster one after the other (disabled by default)
- MULTI_CORE_P=1: this enables the parallel multi-core execution, meaning the iDMA is used by all the cores in the cluster in parallel (disabled by default)

The supported tests are:

- **idma_multi_core**: tests the iDMA 1D transfer capabilities
- **idma_multi_core_2d**: tests the iDMA 2D transfer capabilities
- **idma_multi_core_3d**: tests the iDMA 3D transfer capabilities
- **idma_benchmark_tests**: this one allows to test three different scenarios, depending ont the following command-line flags:
    - TX=1: tests a L1 -> L2 1D transfer
    - RX=1: tests a L2 -> L1 1D transfer
    - TX_RX: tests a L1 -> L2 and a L2 -> L1 transfer in parallel
    - IDLE=1: iDMA does nothing, while the transfer is executed by the core

Random stimuli generation is also supported for iDMA testing. While pre-generated stimuli are already available, you can generate your own:

``` bash
make stimuli # depending on the chosen test, this generates testcase-specific stimuli
```

### Pulp-sdk flow

Clone the software stack [here](https://github.com/FondazioneChipsIT/pulp-sdk) (tests are already included).

Then:

``` bash
# From the top pulp_open dir

# Setup the toolchain, on Chips-IT machines the following is true:

export PULP_RISCV_GCC_TOOLCHAIN=/opt/riscv/pulp-gcc-1.0.16/
source setup/vsim.sh # This sets the needed VSIM_PATH env variable

source pulp-sdk/configs/pulp_open.sh # This sets the environment for pulp open simulation

cd tests/idma/idma_1d # Move to the tests directories
make clean all run platform=rtl # Compile and execute the test in console mode on the rtl platform
```

While most of the flow is identical to the pulp-runtime one, a few specifications:

- Use ***run_gui*** to launch graphical mode
- GVSOC simulation is not supported yet for this instance of iDMA
- Randomized stimuli generation works the same way as pulp-runtime
- Multi-core execution can be enabled through MULTI_CORE_S and MULTI_CORE_P
- Use DEBUG_TEST=1 to enable printfs
