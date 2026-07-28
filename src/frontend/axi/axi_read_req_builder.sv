// Read Request Builder (TX): attivo quando direction_i=0.
// Traduce la descrizione di burst generica (indirizzo, num_beats) fornita
// da axi_cmd_fsm nei segnali attesi da idma_axi_read (ar_req / r_dp_req).
//
// ar_req_o è del tipo ANNIDATO atteso dalla porta ar_req_i di
// idma_axi_read (read_meta_channel_t, con dentro .axi.ar_chan) — non il
// solo canale AR "nudo" — così si collega direttamente senza wrapper
// aggiuntivi nel top.
module axi_read_req_builder #(
    parameter int unsigned AddrWidth        = 32,
    parameter int unsigned StrbWidth        = 4,
    parameter int unsigned BurstBeats       = 8,
    parameter type         read_meta_chan_t = logic, // es. read_meta_channel_t (con .axi.ar_chan)
    parameter type         r_dp_req_t       = logic
) (
    // Selettore direzione da axi_cmd_fsm
    input logic direction_i, // 0 = TX, questo builder è attivo

    // Descrizione burst generica da axi_cmd_fsm
    input logic [AddrWidth-1:0]          burst_addr_i,
    input logic [$clog2(BurstBeats)-1:0] burst_num_beats_i,
    input logic                          burst_is_single_i,
    input logic                          burst_valid_i,
    output logic                         burst_ready_o,

    //--------------------------------------
    // Verso idma_axi_read
    //--------------------------------------
    output read_meta_chan_t ar_req_o,   // -> ar_req_i di idma_axi_read
    output logic            ar_valid_o, // -> ar_valid_i
    input  logic            ar_ready_i, // <- ar_ready_o

    output r_dp_req_t r_dp_req_o,  // -> r_dp_req_i
    output logic      r_dp_valid_o, // -> r_dp_valid_i
    input  logic      r_dp_ready_i  // <- r_dp_ready_o
);

  logic active;
  assign active = burst_valid_i & ~direction_i;

  always_comb begin
    ar_req_o = '0;
    ar_req_o.axi.ar_chan.addr  = burst_addr_i;
    ar_req_o.axi.ar_chan.len   = burst_num_beats_i;
    ar_req_o.axi.ar_chan.size  = $clog2(StrbWidth);
    ar_req_o.axi.ar_chan.burst = axi_pkg::BURST_INCR;
  end

  always_comb begin
    r_dp_req_o           = '0;
    r_dp_req_o.offset    = '0; // sempre word-aligned
    r_dp_req_o.tailer    = StrbWidth;
    r_dp_req_o.shift     = '0;
    r_dp_req_o.is_single = burst_is_single_i;
  end

  assign ar_valid_o   = active;
  assign r_dp_valid_o = active;

  // Il burst è considerato accettato/completato quando ENTRAMBI i lati
  // segnalano ready: ar_ready_i (il comando AR è stato accettato dal bus)
  // e r_dp_ready_i. Attenzione: r_dp_ready_i (= r_dp_ready_o del modulo
  // idma_axi_read) NON è un semplice ack immediato — si alza solo quando
  // l'ULTIMO beat del burst è arrivato (r_dp_valid_i & r_dp_ready_i &
  // read_rsp_i.r.last & ...), quindi burst_ready_o riflette
  // correttamente "il burst intero è stato completato", non solo
  // "il comando è stato accettato". La FSM a monte deve aspettare questo
  // prima di avanzare al prossimo burst.
  assign burst_ready_o = active & ar_ready_i & r_dp_ready_i;

endmodule