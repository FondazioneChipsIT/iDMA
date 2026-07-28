// Package containing the shared types between reg_mem_ctrl and downstream modules
// (REG to CMD FIFOs, etc.)

package mem_ctrl_reg_pkg;

  typedef struct packed {
    logic [1:0]  protocol;           // Hyper, SD, eMMC
    logic [2:0]  transaction_type;   // data/reg, R/W, or SD command
    logic [3:0]  response_type;      // only for SD commands
    logic [9:0]  data_size;
    logic [31:0] external_address;   // external address (or SD command)
    logic [31:0] internal_address;   // AXI master address (32 bits)
    logic        transaction_valid;
  } reg2hw_t;

  typedef struct packed {
    logic busy;
    logic done;
    logic error;
  } hw2reg_t;

endpackage