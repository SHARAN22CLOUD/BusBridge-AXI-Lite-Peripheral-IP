`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Module : register_bank
// Purpose:
// Stores all memory-mapped registers for the AXI-Lite peripheral.
//
// Register Map
// 0x00 : CONTROL   (R/W)
// 0x04 : STATUS    (Read + HW Update)
// 0x08 : DATA_IN   (R/W)
// 0x0C : DATA_OUT  (Read + HW Update)
//////////////////////////////////////////////////////////////////////////////////

module register_bank(

    input clk,
    input rst,

    // AXI Write Interface
    input write_en,
    input [31:0] addr,
    input [31:0] write_data,

    // Hardware Updates
    input [31:0] status_update,
    input status_we,

    input [31:0] data_out_update,
    input data_out_we,

    // Read Data
    output reg [31:0] read_data,

    // Register Outputs
    output [31:0] control_reg_out,
    output [31:0] data_in_reg_out

);

    //----------------------------------------------------------
    // Register Address Map
    //----------------------------------------------------------

    localparam CONTROL_ADDR  = 32'h00000000;
    localparam STATUS_ADDR   = 32'h00000004;
    localparam DATA_IN_ADDR  = 32'h00000008;
    localparam DATA_OUT_ADDR = 32'h0000000C;

    //----------------------------------------------------------
    // Internal Registers
    //----------------------------------------------------------

    reg [31:0] control_reg;
    reg [31:0] status_reg;
    reg [31:0] data_in_reg;
    reg [31:0] data_out_reg;

    //----------------------------------------------------------
    // Write Logic
    //----------------------------------------------------------

    always @(posedge clk or posedge rst) begin

        if(rst) begin

            control_reg <= 32'd0;
            status_reg  <= 32'd0;
            data_in_reg <= 32'd0;
            data_out_reg<= 32'd0;

        end
        else begin

            // AXI writes

            if(write_en) begin

                case(addr)

                    CONTROL_ADDR:
                        control_reg <= write_data;

                    DATA_IN_ADDR:
                        data_in_reg <= write_data;

                    default: ;

                endcase

            end

            // Hardware writes

            if(status_we)
                status_reg <= status_update;

            if(data_out_we)
                data_out_reg <= data_out_update;

        end

    end

    //----------------------------------------------------------
    // Read Logic
    //----------------------------------------------------------

    always @(*) begin

        case(addr)

            CONTROL_ADDR:
                read_data = control_reg;

            STATUS_ADDR:
                read_data = status_reg;

            DATA_IN_ADDR:
                read_data = data_in_reg;

            DATA_OUT_ADDR:
                read_data = data_out_reg;

            default:
                read_data = 32'hDEADBEEF;

        endcase

    end

    //----------------------------------------------------------
    // Outputs
    //----------------------------------------------------------

    assign control_reg_out = control_reg;
    assign data_in_reg_out = data_in_reg;

endmodule