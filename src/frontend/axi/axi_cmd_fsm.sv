import mem_ctrl_reg_pkg::*;

// FSM di splitting/dispatch: consuma un comando alla volta dalla
// axi_cmd_fifo (pop_i/empty_o), tiene lo stato del burst corrente
// (indirizzo, beat rimanenti) e lo espone verso due Request Builder
// ESTERNI (uno per TX/read, uno per RX/write). Questo modulo non
// costruisce mai direttamente ar_req/aw_req/r_dp_req/w_dp_req: si limita
// a dire "questo è il prossimo burst" (addr, num_beats, direzione) e ad
// aspettare un ack dal builder attivo.
module axi_cmd_fsm #(
    parameter int unsigned AddrWidth  = 32,
    parameter int unsigned StrbWidth  = 4,  // 32-bit data width / 8
    parameter int unsigned BurstBeats = 8   // profondità della FIFO fisica HyperBus
) (
    input logic clk_i,
    input logic rst_ni,

    //--------------------------------------
    // Consumo da axi_cmd_fifo
    //--------------------------------------
    input  axi_cmd_t axi_cmd_i,   // data_o della axi_cmd_fifo
    input  logic     axi_empty_i, // empty_o della axi_cmd_fifo
    output logic     axi_pop_o,   // pop_i verso la axi_cmd_fifo

    //--------------------------------------
    // Verso i Request Builder esterni
    //--------------------------------------
    // Direzione del comando corrente: 0 = TX (read AXI / dest FIFO),
    // 1 = RX (source FIFO / write AXI). Stabile per tutta la durata
    // del comando (da IDLE->ACTIVE fino a DONE).
    output logic direction_o,

    // Descrizione del burst corrente, valida quando burst_valid_o=1.
    // Il builder attivo (TX o RX, selezionato in base a direction_o)
    // la traduce nei propri segnali (ar_req/r_dp_req oppure
    // aw_req/w_dp_req) e genera burst_ready_i quando accettata.
    output logic [AddrWidth-1:0]        burst_addr_o,
    output logic [$clog2(BurstBeats)-1:0] burst_num_beats_o, // 0 = 1 beat
    output logic                        burst_is_single_o,
    output logic                        burst_valid_o,
    input  logic                        burst_ready_i,

    //--------------------------------------
    // Stato verso reg_mem_ctrl / SW (hw2reg.status)
    //--------------------------------------
    output logic busy_o,
    output logic done_o,   // impulso di un ciclo a fine comando
    output logic error_o
);

  typedef enum logic [1:0] {
    IDLE,
    ACTIVE,
    DONE
  } state_e;

  state_e state_q, state_d;

  logic direction_q, direction_d;
  logic [AddrWidth-1:0] cur_addr_q, cur_addr_d;
  logic [9:0]           remaining_q, remaining_d; // data_size è 10 bit

  logic [9:0] max_burst_bytes;
  assign max_burst_bytes = BurstBeats[9:0] * StrbWidth[9:0];

  logic [9:0] bytes_this_burst;
  assign bytes_this_burst = (remaining_q > max_burst_bytes) ? max_burst_bytes : remaining_q;

  logic [$clog2(BurstBeats)-1:0] num_beats;
  assign num_beats = (bytes_this_burst[9:$clog2(StrbWidth)] == 0)
                     ? '0
                     : bytes_this_burst[9:$clog2(StrbWidth)] - 1;

  //--------------------------------------
  // Uscite verso i builder esterni
  //--------------------------------------
  assign direction_o        = direction_q;
  assign burst_addr_o       = cur_addr_q;
  assign burst_num_beats_o  = num_beats;
  assign burst_is_single_o  = (num_beats == 0);
  assign burst_valid_o      = (state_q == ACTIVE);

  logic burst_accepted;
  assign burst_accepted = burst_valid_o & burst_ready_i;

  //--------------------------------------
  // FSM
  //--------------------------------------
  always_comb begin
    state_d     = state_q;
    direction_d = direction_q;
    cur_addr_d  = cur_addr_q;
    remaining_d = remaining_q;
    axi_pop_o   = 1'b0;
    done_o      = 1'b0;

    unique case (state_q)

      IDLE: begin
        if (~axi_empty_i) begin
          axi_pop_o   = 1'b1;
          direction_d = axi_cmd_i.transaction_type;
          cur_addr_d  = axi_cmd_i.internal_address;
          remaining_d = axi_cmd_i.data_size;
          state_d     = ACTIVE;
        end
      end

      ACTIVE: begin
        if (burst_accepted) begin
          if (remaining_q <= bytes_this_burst) begin
            remaining_d = '0;
            state_d     = DONE;
          end else begin
            remaining_d = remaining_q - bytes_this_burst;
            cur_addr_d  = cur_addr_q + bytes_this_burst;
          end
        end
      end

      DONE: begin
        done_o  = 1'b1;
        state_d = IDLE;
      end

      default: state_d = IDLE;

    endcase
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state_q     <= IDLE;
      direction_q <= 1'b0;
      cur_addr_q  <= '0;
      remaining_q <= '0;
    end else begin
      state_q     <= state_d;
      direction_q <= direction_d;
      cur_addr_q  <= cur_addr_d;
      remaining_q <= remaining_d;
    end
  end

  assign busy_o  = (state_q != IDLE);
  // error_o: nessun error handler collegato ancora. Da aggiornare quando
  // si integreranno le risposte r_dp_rsp/w_dp_rsp dai builder esterni.
  assign error_o = 1'b0;

endmodule