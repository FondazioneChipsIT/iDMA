 // Generic synchronous FIFO, ready/valid protocol, parameterizable depth.
 // No CDC: push and pop operations occur on the same clk_i.
module sync_fifo #(
    parameter type         data_t = logic,
    parameter int unsigned Depth  = 8
) (
    input logic clk_i,
    input logic rst_ni,

    // Input (push)
    input  data_t data_i,
    input  logic  valid_i,
    output logic  ready_o,

    // Output (pop)
    output data_t data_o,
    output logic  valid_o,
    input  logic  ready_i,

    // Status signals, useful for debug/status registers
    output logic                        full_o,
    output logic                        empty_o,
    output logic [$clog2(Depth+1)-1:0]  usage_o
);

  localparam int unsigned PtrWidth = $clog2(Depth);

  data_t [Depth-1:0] mem_q;

  logic [PtrWidth-1:0] wr_ptr_q, wr_ptr_d;
  logic [PtrWidth-1:0] rd_ptr_q, rd_ptr_d;
  logic [$clog2(Depth+1)-1:0] usage_q, usage_d;

  assign empty_o = (usage_q == '0);
  assign full_o  = (usage_q == Depth);
  assign usage_o = usage_q;

  assign ready_o = ~full_o;
  assign valid_o = ~empty_o;
  assign data_o = valid_o ? mem_q[rd_ptr_q] : '0;

  logic push;
  logic pop;
  assign push = valid_i & ready_o;
  assign pop  = valid_o & ready_i;

  always_comb begin
    wr_ptr_d = wr_ptr_q;
    rd_ptr_d = rd_ptr_q;
    usage_d  = usage_q;

    if (push) begin
      wr_ptr_d = (wr_ptr_q == Depth-1) ? '0 : wr_ptr_q + 1;
    end

    if (pop) begin
      rd_ptr_d = (rd_ptr_q == Depth-1) ? '0 : rd_ptr_q + 1;
    end

    unique case ({push, pop})
      2'b10:   usage_d = usage_q + 1;
      2'b01:   usage_d = usage_q - 1;
      default: usage_d = usage_q; // 00: no change, 11: push and pop balance each other
    endcase
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      wr_ptr_q <= '0;
      rd_ptr_q <= '0;
      usage_q  <= '0;
    end else begin
      wr_ptr_q <= wr_ptr_d;
      rd_ptr_q <= rd_ptr_d;
      usage_q  <= usage_d;
    end
  end

  always_ff @(posedge clk_i) begin
    if (push) begin
      mem_q[wr_ptr_q] <= data_i;
    end
  end

  `ifndef SYNTHESIS
  // Assertions: never push into a full FIFO, never pop from an empty FIFO
  assert property (@(posedge clk_i) disable iff (!rst_ni) valid_i |-> !( !ready_o && valid_i ))
    else $error("sync_fifo: push attempted while full");
  assert property (@(posedge clk_i) disable iff (!rst_ni) ready_i |-> !( !valid_o && ready_i ))
    else $warning("sync_fifo: pop attempted while empty (may be benign if ready_i is unconditional)");
  `endif

endmodule