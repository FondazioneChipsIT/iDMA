import mem_ctrl_reg_pkg::*;

module reg_mem_ctrl #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
) (
    input logic clk_i,
    input logic rst_ni,

    //--------------------------------------
    // APB2REG interface
    //--------------------------------------
    input  logic                  reg_we_i,
    input  logic                  reg_re_i,
    input  logic [ADDR_WIDTH-1:0] reg_addr_i,
    input  logic [DATA_WIDTH-1:0] reg_wdata_i,

    output logic [DATA_WIDTH-1:0] reg_rdata_o,

    //--------------------------------------
    // Hardware interface
    //--------------------------------------
    output reg2hw_t reg2hw_o,
    input  hw2reg_t hw2reg_i,

    // One-cycle pulse: high when SW writes 1 to transaction_valid.
    // Used as a trigger towards reg_to_cmd_fifos.
    output logic transaction_valid_pulse_o,

    // Available space in both Command FIFOs (from reg_to_cmd_fifos).
    // Used to block transaction_valid writes until space is available:
    // real backpressure on the APB bus.
    input logic space_available_i,

    // Ready signal towards apb2reg: low only when attempting to write
    // transaction_valid=1 while the FIFOs have no available space.
    // For all other transactions (reads, writes to other registers) it
    // remains always high.
    output logic reg_ready_o
);

  // Register offsets (byte addresses, aligned to 4-byte words)
  localparam logic [ADDR_WIDTH-1:0] ConfOffset      = 8'h00;
  localparam logic [ADDR_WIDTH-1:0] DataSizeOffset   = 8'h04;
  localparam logic [ADDR_WIDTH-1:0] ExtAddrOffset    = 8'h08;
  localparam logic [ADDR_WIDTH-1:0] IntAddrOffset    = 8'h0C;
  localparam logic [ADDR_WIDTH-1:0] TransValidOffset = 8'h10;
  localparam logic [ADDR_WIDTH-1:0] StatusOffset     = 8'h14;

  // Attempt to write transaction_valid=1: raw condition,
  // before checking whether FIFO space is available.
  logic transaction_valid_write_attempt;
  assign transaction_valid_write_attempt =
      reg_we_i & (reg_addr_i == TransValidOffset) & reg_wdata_i[0];

  // Ready signal towards apb2reg: low only during a transaction_valid=1
  // write attempt while the FIFOs have no available space. Blocks the APB
  // bus (pready_o) until space becomes available.
  assign reg_ready_o = ~(transaction_valid_write_attempt & ~space_available_i);

  // Trigger towards reg_to_cmd_fifos is asserted only when the write
  // operation has actually been accepted (space was available): one cycle,
  // synchronized with the actual update of reg2hw_o.transaction_valid below.
  assign transaction_valid_pulse_o = transaction_valid_write_attempt & space_available_i;

  //--------------------------------------
  // Register write (SW -> HW)
  //--------------------------------------
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      reg2hw_o <= '0;
    end else if (reg_we_i) begin
      unique case (reg_addr_i)
        ConfOffset: begin
          reg2hw_o.protocol         <= reg_wdata_i[1:0];
          reg2hw_o.transaction_type <= reg_wdata_i[4:2];
          reg2hw_o.response_type    <= reg_wdata_i[8:5];
        end

        DataSizeOffset:
          reg2hw_o.data_size <= reg_wdata_i[9:0];

        ExtAddrOffset:
          reg2hw_o.external_address <= reg_wdata_i;

        IntAddrOffset:
          reg2hw_o.internal_address <= reg_wdata_i;

        TransValidOffset: begin
          // Write only if the bus is not blocked due to lack of FIFO space
          // (see reg_ready_o). If reg_ready_o is low, the same APB cycle
          // will be repeated by the master (wait state) until space becomes
          // available, therefore the register is not updated yet.
          if (reg_ready_o) begin
            reg2hw_o.transaction_valid <= reg_wdata_i[0];
          end
        end

        default: ; // Unknown register: no write operation
      endcase
    end
  end

  //--------------------------------------
  // Register read (HW -> SW)
  //--------------------------------------
  always_comb begin
    reg_rdata_o = '0;

    unique case (reg_addr_i)
      ConfOffset: begin
        reg_rdata_o[1:0] = reg2hw_o.protocol;
        reg_rdata_o[4:2] = reg2hw_o.transaction_type;
        reg_rdata_o[8:5] = reg2hw_o.response_type;
      end

      DataSizeOffset:
        reg_rdata_o[9:0] = reg2hw_o.data_size;

      ExtAddrOffset:
        reg_rdata_o = reg2hw_o.external_address;

      IntAddrOffset:
        reg_rdata_o = reg2hw_o.internal_address;

      TransValidOffset:
        reg_rdata_o[0] = reg2hw_o.transaction_valid;

      StatusOffset: begin
        reg_rdata_o[0] = hw2reg_i.busy;
        reg_rdata_o[1] = hw2reg_i.done;
        reg_rdata_o[2] = hw2reg_i.error;
      end

      default: reg_rdata_o = '0;
    endcase
  end

endmodule