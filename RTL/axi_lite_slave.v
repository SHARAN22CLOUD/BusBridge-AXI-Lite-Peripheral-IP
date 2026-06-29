`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Module : axi_lite_slave
//
// Purpose:
// Simple AXI-Lite Slave Interface
//
// Supported Registers:
// CONTROL
// STATUS
// DATA_IN
// DATA_OUT
//
// This implementation supports one outstanding transaction at a time.
// It is suitable for educational and internship projects.
//////////////////////////////////////////////////////////////////////////////////

module axi_lite_slave(

    input clk,
    input rst,

    //-----------------------------
    // AXI Write Address Channel
    //-----------------------------
    input [31:0] AWADDR,
    input AWVALID,
    output AWREADY,

    //-----------------------------
    // AXI Write Data Channel
    //-----------------------------
    input [31:0] WDATA,
    input WVALID,
    output WREADY,

    //-----------------------------
    // Write Response
    //-----------------------------
    output [1:0] BRESP,
    output BVALID,
    input BREADY,

    //-----------------------------
    // Read Address
    //-----------------------------
    input [31:0] ARADDR,
    input ARVALID,
    output ARREADY,

    //-----------------------------
    // Read Data
    //-----------------------------
    output [31:0] RDATA,
    output RVALID,
    input RREADY,

    //-----------------------------
    // Register Bank Interface
    //-----------------------------
    output write_en,
    output [31:0] addr,
    output [31:0] write_data,

    input [31:0] read_data

);

    //---------------------------------------------------
    // Always Ready
    //---------------------------------------------------

    assign AWREADY = 1'b1;
    assign WREADY  = 1'b1;
    assign ARREADY = 1'b1;

    //---------------------------------------------------
    // Write Interface
    //---------------------------------------------------

    assign write_en  = AWVALID && WVALID;

    assign addr      = (AWVALID) ? AWADDR : ARADDR;

    assign write_data = WDATA;

    //---------------------------------------------------
    // Write Response
    //---------------------------------------------------

    assign BRESP = 2'b00;      // OKAY Response

    assign BVALID = write_en;

    //---------------------------------------------------
    // Read Interface
    //---------------------------------------------------

    assign RDATA = read_data;

    assign RVALID = ARVALID;

endmodule