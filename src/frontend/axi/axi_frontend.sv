// Collega axi_cmd_fsm ai due Request Builder esterni (TX/read e RX/write),
// e mostra il collegamento reale di axi_read_req_builder a idma_axi_read
// (il lato write, idma_axi_write, si collega in modo analogo).
// Frontend AXI: FSM di dispatch + i due Request Builder (TX/read e
// RX/write). NON istanzia idma_axi_read/idma_axi_write: espone verso
// l'esterno le porte generiche (ar_req_o/..., aw_req_o/...) nel formato
// annidato atteso da quei moduli, così un top superiore può includerli
// insieme al backend AXI vero e proprio.
module axi_frontend #(
    parameter int unsigned AddrWidth         = 32,
    parameter int unsigned StrbWidth         = 4,
    parameter int unsigned BurstBeats        = 8,
    parameter type         read_meta_chan_t  = logic, // read_meta_channel_t
    parameter type         write_meta_chan_t = logic, // write_meta_channel_t
    parameter type         r_dp_req_t        = logic,
    parameter type         w_dp_req_t        = logic
) (
    input logic clk_i,
    input logic rst_ni,

    input  axi_cmd_t axi_cmd_i,
    input  logic     axi_empty_i,
    output logic     axi_pop_o,

    //--------------------------------------
    // Verso idma_axi_read (esterno, istanziato dal top superiore)
    //--------------------------------------
    output read_meta_chan_t ar_req_o,
    output logic            ar_valid_o,
    input  logic            ar_ready_i,
    output r_dp_req_t       r_dp_req_o,
    output logic            r_dp_valid_o,
    input  logic            r_dp_ready_i,

    //--------------------------------------
    // Verso idma_axi_write (esterno, istanziato dal top superiore)
    //--------------------------------------
    output write_meta_chan_t aw_req_o,
    output logic             aw_valid_o,
    input  logic              aw_ready_i,
    output w_dp_req_t         w_dp_req_o,
    output logic              w_dp_valid_o,
    input  logic              w_dp_ready_i,

    output logic busy_o,
    output logic done_o,
    output logic error_o
);

  logic direction;
  logic [AddrWidth-1:0]          burst_addr;
  logic [$clog2(BurstBeats)-1:0] burst_num_beats;
  logic burst_is_single, burst_valid;
  logic burst_ready_tx, burst_ready_rx;

  axi_cmd_fsm #(
      .AddrWidth  (AddrWidth),
      .StrbWidth  (StrbWidth),
      .BurstBeats (BurstBeats)
  ) i_axi_cmd_fsm (
      .clk_i, .rst_ni,

      .axi_cmd_i, .axi_empty_i, .axi_pop_o,

      .direction_o       (direction),
      .burst_addr_o      (burst_addr),
      .burst_num_beats_o (burst_num_beats),
      .burst_is_single_o (burst_is_single),
      .burst_valid_o     (burst_valid),
      // solo uno dei due builder è realmente attivo per volta: OR sicuro
      .burst_ready_i     (burst_ready_tx | burst_ready_rx),

      .busy_o, .done_o, .error_o
  );

  axi_read_req_builder #(
      .AddrWidth        (AddrWidth),
      .StrbWidth        (StrbWidth),
      .BurstBeats       (BurstBeats),
      .read_meta_chan_t (read_meta_chan_t),
      .r_dp_req_t       (r_dp_req_t)
  ) i_axi_read_req_builder (
      .direction_i (direction),

      .burst_addr_i      (burst_addr),
      .burst_num_beats_i (burst_num_beats),
      .burst_is_single_i (burst_is_single),
      .burst_valid_i     (burst_valid),
      .burst_ready_o     (burst_ready_tx),

      .ar_req_o, .ar_valid_o, .ar_ready_i,
      .r_dp_req_o, .r_dp_valid_o, .r_dp_ready_i
  );

  axi_write_req_builder #(
      .AddrWidth         (AddrWidth),
      .StrbWidth         (StrbWidth),
      .BurstBeats        (BurstBeats),
      .write_meta_chan_t (write_meta_chan_t),
      .w_dp_req_t        (w_dp_req_t)
  ) i_axi_write_req_builder (
      .direction_i (direction),

      .burst_addr_i      (burst_addr),
      .burst_num_beats_i (burst_num_beats),
      .burst_is_single_i (burst_is_single),
      .burst_valid_i     (burst_valid),
      .burst_ready_o     (burst_ready_rx),

      .aw_req_o, .aw_valid_o, .aw_ready_i,
      .w_dp_req_o, .w_dp_valid_o, .w_dp_ready_i
  );

endmodule