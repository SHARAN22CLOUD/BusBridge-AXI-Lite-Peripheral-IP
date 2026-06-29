`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Module : interrupt_controller
//
// Purpose:
// Simulates a hardware accelerator controlled through AXI-Lite registers.
//
// Operation:
// CONTROL[0] = 1  -> Start Processing
// Wait 2 Clock Cycles
// DATA_OUT = DATA_IN << 1
// STATUS = DONE
// interrupt = 1
//
// Software clears CONTROL[0] to return to IDLE.
//////////////////////////////////////////////////////////////////////////////////

module interrupt_controller(

    input clk,
    input rst,

    input [31:0] control_reg,
    input [31:0] data_in_reg,

    output reg [31:0] status_update,
    output reg status_we,

    output reg [31:0] data_out_update,
    output reg data_out_we,

    output reg interrupt

);

    //----------------------------------------------------------
    // FSM States
    //----------------------------------------------------------

    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;
    reg [1:0] count;

    //----------------------------------------------------------
    // FSM
    //----------------------------------------------------------

    always @(posedge clk or posedge rst) begin

        if(rst) begin

            state <= IDLE;
            count <= 2'd0;

            interrupt <= 1'b0;

            status_update <= 32'd0;
            data_out_update <= 32'd0;

            status_we <= 1'b0;
            data_out_we <= 1'b0;

        end

        else begin

            // Default write-enable pulses
            status_we <= 1'b0;
            data_out_we <= 1'b0;

            case(state)

                //--------------------------------------------------
                // IDLE
                //--------------------------------------------------

                IDLE: begin

                    interrupt <= 1'b0;

                    if(control_reg[0]) begin
                        count <= 2'd0;
                        state <= BUSY;
                    end

                end

                //--------------------------------------------------
                // BUSY
                //--------------------------------------------------

                BUSY: begin

                    count <= count + 1'b1;

                    if(count == 2'd2) begin

                        // DATA_OUT = DATA_IN × 2
                        data_out_update <= data_in_reg << 1;
                        data_out_we <= 1'b1;

                        // STATUS = DONE
                        status_update <= 32'h00000001;
                        status_we <= 1'b1;

                        interrupt <= 1'b1;

                        state <= DONE;

                    end

                end

                //--------------------------------------------------
                // DONE
                //--------------------------------------------------

                DONE: begin

                    if(!control_reg[0]) begin

                        interrupt <= 1'b0;

                        status_update <= 32'd0;
                        status_we <= 1'b1;

                        count <= 2'd0;

                        state <= IDLE;

                    end

                end

                default: begin
                    state <= IDLE;
                end

            endcase

        end

    end

endmodule