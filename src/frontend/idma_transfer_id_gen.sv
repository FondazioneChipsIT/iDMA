// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Authors:
// - Thomas Benz <tbenz@iis.ee.ethz.ch>

/// DMA transaction id generator. Increases the transaction id on every request.
module idma_transfer_id_gen #(
    parameter int unsigned  IdWidth = -1
) (
    input  logic                clk_i,
    input  logic                rst_ni,
    // new request is pushed
    input  logic                issue_i,
    // request is popped
    input  logic                retire_i,
    // next id is
    output logic [IdWidth-1:0]  next_o,
    // last id completed is
    output logic [IdWidth-1:0]  completed_o
);

    //--------------------------------------
    // counters
    //--------------------------------------
    logic [IdWidth-1:0] next_d, next_q, completed_d, completed_q;

    // count up on events only, and skip 0 (reserved for "not accepted") at the
    // overflow: both counters then take the same IDs, ..., '1, 1, 2, ..., so
    // completed_o is always the ID of the last transfer retired, whether or not
    // the clock keeps running after it
    always_comb begin : proc_next_id
        // default
        next_d = next_q;
        // request
        if (issue_i) begin
            if (next_q == '1) begin
                next_d = 'h1;
            end else begin
                next_d = next_q + 'h1;
            end
        end
    end

    always_comb begin : proc_next_completed
        // default
        completed_d = completed_q;
        // request
        if (retire_i) begin
            if (completed_q == '1) begin
                completed_d = 'h1;
            end else begin
                completed_d = completed_q + 'h1;
            end
        end
    end

    // assign outputs
    assign next_o      = next_q;
    assign completed_o = completed_q;

    //--------------------------------------
    // state
    //--------------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin : proc_id_gen
        if(~rst_ni) begin
            next_q      <= 2;
            completed_q <= 1;
        end else begin
            next_q      <= next_d;
            completed_q <= completed_d;
        end
    end

endmodule : idma_transfer_id_gen
