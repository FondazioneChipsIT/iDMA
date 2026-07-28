import mem_ctrl_reg_pkg::*;

// APB slave top level: groups apb2reg, reg_mem_ctrl, and reg2cmdfifos.
// Exposes the APB interface and the two Command FIFOs externally
// (towards PHY and AXI master), together with the hw2reg status interface.
module apb_slave #(
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
    // Hardware status interface (towards reg_mem_ctrl)
    //--------------------------------------------------
    input hw2reg_t hw2reg_i,

    //--------------------------------------------------
    // CMD FIFO towards PHY (CDC source FIFO)
    //--------------------------------------------------
    output phy_cmd_t phy_cmd_o,
    output logic     phy_cmd_valid_o,
    input  logic     phy_cmd_ready_i,
    input  logic     phy_full_i,

    //--------------------------------------------------
    // CMD FIFO towards AXI master
    //--------------------------------------------------
    output axi_cmd_t axi_cmd_o,
    output logic     axi_cmd_valid_o,
    input  logic     axi_cmd_ready_i,
    input  logic     axi_full_i
);

  //--------------------------------------------------
  // Internal interconnection signals
  //--------------------------------------------------

  // apb2reg <-> reg_mem_ctrl
  logic                  reg_we;
  logic                  reg_re;
  logic [ADDR_WIDTH-1:0] reg_addr;
  logic [DATA_WIDTH-1:0] reg_wdata;
  logic [DATA_WIDTH-1:0] reg_rdata;
  logic                  reg_ready;

  // reg_mem_ctrl <-> reg2cmdfifos
  reg2hw_t reg2hw;
  logic    transaction_valid_pulse;
  logic    space_available;
  logic    push_error;  // not connected externally, kept for internal debug
  logic    sync_error;  // not connected externally, kept for internal debug

  //--------------------------------------------------
  // apb2reg: translates APB transactions into a simple register interface
  //--------------------------------------------------
  apb2reg #(
      .ADDR_WIDTH (ADDR_WIDTH),
      .DATA_WIDTH (DATA_WIDTH)
  ) i_apb2reg (
      .clk_i       (clk_i),
      .rst_ni      (rst_ni),

      .psel_i      (psel_i),
      .penable_i   (penable_i),
      .pwrite_i    (pwrite_i),
      .paddr_i     (paddr_i),
      .pwdata_i    (pwdata_i),

      .prdata_o    (prdata_o),
      .pready_o    (pready_o),
      .pslverr_o   (pslverr_o),

      .reg_we_o    (reg_we),
      .reg_re_o    (reg_re),
      .reg_addr_o  (reg_addr),
      .reg_wdata_o (reg_wdata),

      .reg_rdata_i (reg_rdata),
      .reg_ready_i (reg_ready)
  );

  //--------------------------------------------------
  // reg_mem_ctrl: actual register file
  //--------------------------------------------------
  mem_ctrl_reg_wrap #(
      .ADDR_WIDTH (ADDR_WIDTH),
      .DATA_WIDTH (DATA_WIDTH)
  ) i_reg_mem_ctrl (
      .clk_i      (clk_i),
      .rst_ni     (rst_ni),

      .reg_we_i   (reg_we),
      .reg_re_i   (reg_re),
      .reg_addr_i (reg_addr),
      .reg_wdata_i(reg_wdata),

      .reg_rdata_o(reg_rdata),

      .reg2hw_o   (reg2hw),
      .hw2reg_i   (hw2reg_i),

      .transaction_valid_pulse_o (transaction_valid_pulse),
      .space_available_i         (space_available),
      .reg_ready_o               (reg_ready)
  );

  //--------------------------------------------------
  // reg2cmdfifos: packs reg2hw data into the two Command FIFOs
  //--------------------------------------------------
  reg2cmdfifos i_reg2cmdfifos (
      .clk_i  (clk_i),
      .rst_ni (rst_ni),

      .reg2hw_i (reg2hw),

      .transaction_valid_pulse_i (transaction_valid_pulse),

      .phy_cmd_o       (phy_cmd_o),
      .phy_cmd_valid_o (phy_cmd_valid_o),
      .phy_cmd_ready_i (phy_cmd_ready_i),
      .phy_full_i      (phy_full_i),

      .axi_cmd_o       (axi_cmd_o),
      .axi_cmd_valid_o (axi_cmd_valid_o),
      .axi_cmd_ready_i (axi_cmd_ready_i),
      .axi_full_i      (axi_full_i),

      .push_error_o      (push_error),
      .sync_error_o      (sync_error),
      .space_available_o (space_available)
  );

endmodule