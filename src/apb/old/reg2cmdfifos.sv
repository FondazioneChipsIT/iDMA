import mem_ctrl_reg_pkg2::*;

// Packet sent to the PHY-side CMD FIFO (CDC source FIFO)
typedef struct packed {
  logic [1:0]  protocol;
  logic [2:0]  transaction_type;
  logic [3:0]  response_type;
  logic [9:0]  data_size;
  logic [31:0] external_address;
} phy_cmd_t;

// Packet sent to the AXI master-side CMD FIFO
typedef struct packed {
  logic        transaction_type; // R/W: only 1 bit here, subset of the reg2hw field
  logic [9:0]  data_size;
  logic [31:0] internal_address;
} axi_cmd_t;

module reg2cmdfifos (
    input logic clk_i,
    input logic rst_ni,

    //--------------------------------------
    // Interface from registers
    //--------------------------------------
    input reg2hw_t reg2hw_i,

    // One-cycle pulse: transaction_valid written to 1 by SW.
    // Equivalent to iDMA's next_id.re, but here it is a WRITE trigger
    // (not a read trigger), since transaction_valid is a normal RW register
    // and not a prim_subreg_ext.
    input logic transaction_valid_pulse_i,

    //--------------------------------------
    // CMD FIFO towards PHY (CDC source FIFO)
    //--------------------------------------
    output phy_cmd_t phy_cmd_o,
    output logic     phy_cmd_valid_o,
    input  logic     phy_cmd_ready_i,
    input  logic     phy_full_i,

    //--------------------------------------
    // CMD FIFO towards AXI master
    //--------------------------------------
    output axi_cmd_t axi_cmd_o,
    output logic     axi_cmd_valid_o,
    input  logic     axi_cmd_ready_i,
    input  logic     axi_full_i,

    //--------------------------------------
    // Status towards reg_mem_ctrl / SW
    //--------------------------------------
    output logic push_error_o,  // kept for compatibility/debug, currently always 0
    output logic sync_error_o,  // kept for compatibility/debug, currently always 0

    // Available space in BOTH FIFOs. reg_mem_ctrl uses this signal to
    // decide whether to accept or block (pready_o) the transaction_valid write.
    output logic space_available_o
);

  assign space_available_o = phy_cmd_ready_i & axi_cmd_ready_i;

  // The two FIFOs must advance together: with backpressure applied upstream
  // (reg_mem_ctrl blocks the transaction_valid write until
  // space_available_o is high), when transaction_valid_pulse_i reaches this
  // module, space in BOTH FIFOs is already guaranteed. Therefore, the push
  // always occurs together with the trigger.
  assign phy_cmd_valid_o = transaction_valid_pulse_i;
  assign axi_cmd_valid_o = transaction_valid_pulse_i;

  // Kept for compatibility/debug: with upstream backpressure, this condition
  // should never occur (the write is blocked before this trigger can arrive
  // without available space). Useful as an assertion/check.
  assign push_error_o = transaction_valid_pulse_i & ~space_available_o;
  assign sync_error_o = phy_full_i ^ axi_full_i;

  //--------------------------------------
  // Packet construction
  //--------------------------------------
  always_comb begin
    phy_cmd_o = '{
      protocol:         reg2hw_i.protocol,
      transaction_type: reg2hw_i.transaction_type,
      response_type:    reg2hw_i.response_type,
      data_size:        reg2hw_i.data_size,
      external_address: reg2hw_i.external_address
    };

    axi_cmd_o = '{
      // Only the least significant bit of transaction_type is used:
      // assumes bit 0 encodes R/W. To be reviewed if the actual encoding
      // is different.
      transaction_type: reg2hw_i.transaction_type[0],
      data_size:        reg2hw_i.data_size,
      internal_address: reg2hw_i.internal_address
    };
  end

endmodule