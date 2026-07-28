module apb2reg #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
) (
    input logic clk_i,
    input logic rst_ni,

    //--------------------------------------------------
    // APB Slave
    //--------------------------------------------------
    input  logic                  psel_i,
    input  logic                  penable_i,
    input  logic                  pwrite_i,
    input  logic [ADDR_WIDTH-1:0] paddr_i,
    input  logic [DATA_WIDTH-1:0] pwdata_i,

    output logic [DATA_WIDTH-1:0] prdata_o,
    output logic                  pready_o,
    output logic                  pslverr_o,

    //--------------------------------------------------
    // Register interface
    //--------------------------------------------------
    output logic                  reg_we_o,
    output logic                  reg_re_o,
    output logic [ADDR_WIDTH-1:0] reg_addr_o,
    output logic [DATA_WIDTH-1:0] reg_wdata_o,

    input  logic [DATA_WIDTH-1:0] reg_rdata_i,

    // Ready signal from reg_mem_ctrl: low when the register being written
    // cannot accept the write operation at the moment (e.g. transaction_valid
    // while the Command FIFO is full). Propagated to pready_o to generate
    // real wait states on the APB bus.
    input  logic                  reg_ready_i
);

  // Valid APB transaction: ACCESS phase (psel high for at least one cycle, penable high)
  logic apb_access;
  assign apb_access = psel_i & penable_i;

  // Address and write data: propagated only during a valid transaction,
  // preventing reg_mem_ctrl from seeing a "phantom" reg_addr_o when psel_i=0
  assign reg_addr_o  = apb_access ? paddr_i  : '0;
  assign reg_wdata_o = apb_access ? pwdata_i : '0;

  assign reg_we_o = apb_access & pwrite_i;
  assign reg_re_o = apb_access & ~pwrite_i;

  // The register file responds combinationally in the same cycle for
  // most registers (zero-wait-state). For transaction_valid,
  // reg_mem_ctrl can signal "not ready yet" (reg_ready_i=0) if the
  // downstream Command FIFO is full: this generates a real APB wait state
  // (pready_o=0), and the master repeats the ACCESS phase until space
  // becomes available.
  assign prdata_o  = apb_access & ~pwrite_i ? reg_rdata_i : '0;
  assign pready_o  = ~apb_access | reg_ready_i;
  assign pslverr_o = 1'b0;

endmodule