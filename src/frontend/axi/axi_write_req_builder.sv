// Write Request Builder (RX): attivo quando direction_i=1.
// Traduce la descrizione di burst generica (indirizzo, num_beats) fornita
// da axi_cmd_fsm nei segnali attesi da idma_axi_write (aw_req / w_dp_req).
//
// aw_req_o è del tipo ANNIDATO atteso dalla porta aw_req_i di
// idma_axi_write (write_meta_channel_t, con dentro .axi.aw_chan) — non il
// solo canale AW "nudo" — così si collega direttamente senza wrapper
// aggiuntivi nel top, stesso pattern di axi_read_req_builder.
module axi_write_req_builder #(
    parameter int unsigned AddrWidth        = 32,
    parameter int unsigned StrbWidth        = 4,
    parameter int unsigned BurstBeats       = 8,
    parameter type         write_meta_chan_t = logic, // es. write_meta_channel_t (con .axi.aw_chan)
    parameter type         w_dp_req_t        = logic
) (
    // Selettore direzione da axi_cmd_fsm
    input logic direction_i, // 1 = RX, questo builder è attivo

    // Descrizione burst generica da axi_cmd_fsm
    input logic [AddrWidth-1:0]          burst_addr_i,
    input logic [$clog2(BurstBeats)-1:0] burst_num_beats_i,
    input logic                          burst_is_single_i,
    input logic                          burst_valid_i,
    output logic                         burst_ready_o,

    //--------------------------------------
    // Verso idma_axi_write
    //--------------------------------------
    output write_meta_chan_t aw_req_o,    // -> aw_req_i di idma_axi_write
    output logic             aw_valid_o,  // -> aw_valid_i
    input  logic             aw_ready_i,  // <- aw_ready_o

    output w_dp_req_t w_dp_req_o,   // -> w_dp_req_i
    output logic      w_dp_valid_o, // -> w_dp_valid_i
    input  logic      w_dp_ready_i  // <- w_dp_ready_o
);

  logic active;
  assign active = burst_valid_i & direction_i;

  always_comb begin
    aw_req_o = '0;
    aw_req_o.axi.aw_chan.addr  = burst_addr_i;
    aw_req_o.axi.aw_chan.len   = burst_num_beats_i;
    aw_req_o.axi.aw_chan.size  = $clog2(StrbWidth);
    aw_req_o.axi.aw_chan.burst = axi_pkg::BURST_INCR;
  end

  always_comb begin
    w_dp_req_o           = '0;
    w_dp_req_o.offset    = '0; // sempre word-aligned
    w_dp_req_o.tailer    = StrbWidth;
    w_dp_req_o.shift     = '0;
    w_dp_req_o.num_beats = burst_num_beats_i;
    w_dp_req_o.is_single = burst_is_single_i;
  end

  assign aw_valid_o   = active;
  assign w_dp_valid_o = active;

  // Il burst è considerato accettato/completato quando ENTRAMBI i lati
  // segnalano ready: aw_ready_i (il comando AW è stato accettato dal bus)
  // e w_dp_ready_i. Attenzione, comportamento DIVERSO da idma_axi_read:
  // w_dp_ready_i (= w_dp_ready_o del modulo idma_axi_write) si alza solo
  // quando l'ultimo beat è stato scritto sul bus (last_w & write_happening),
  // e write_happening a sua volta dipende dal fatto che il buffer dati
  // (buffer_out_valid_i, lato dataflow_element) abbia effettivamente i
  // dati pronti — non basta che il comando AW sia stato accettato. Quindi
  // burst_ready_o qui riflette "il burst è stato scritto per intero E il
  // buffer aveva sempre i dati pronti in tempo", non solo "AW accettato".
  // Se il buffer non alimenta dati in tempo, w_dp_ready_i resta basso e
  // la FSM a monte resta bloccata in attesa, correttamente.
  assign burst_ready_o = active & aw_ready_i & w_dp_ready_i;

endmodule