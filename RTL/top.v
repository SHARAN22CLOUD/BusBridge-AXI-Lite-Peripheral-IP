`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company      : Student Project
// Engineer     : Your Name
//
// Design Name  : BusBridge - AXI-Lite Peripheral IP
// Module Name  : top
//
// Description:
// Top-level integration of the AXI-Lite Peripheral.
//
// Connected Modules:
// 1. AXI-Lite Slave Interface
// 2. Register Bank
// 3. Interrupt Controller
//
// Data Flow:
//
// CPU
//   │
//   ▼
// AXI-Lite Slave
//   │
//   ▼
// Register Bank
//   │
//   ▼
// Interrupt Controller
//   │
//   ├── STATUS Update
//   ├── DATA_OUT Update
//   └── Interrupt Output
//
//////////////////////////////////////////////////////////////////////////////////

module top(

    //----------------------------------------------------------
    // Global Signals
    //----------------------------------------------------------

    input clk,
    input rst,

    //----------------------------------------------------------
    // AXI Write Address Channel
    //----------------------------------------------------------

    input  [31:0] AWADDR,
    input         AWVALID,
    output        AWREADY,

    //----------------------------------------------------------
    // AXI Write Data Channel
    //----------------------------------------------------------

    input  [31:0] WDATA,
    input         WVALID,
    output        WREADY,

    //----------------------------------------------------------
    // AXI Write Response Channel
    //----------------------------------------------------------

    output [1:0] BRESP,
    output       BVALID,
    input        BREADY,

    //----------------------------------------------------------
    // AXI Read Address Channel
    //----------------------------------------------------------

    input  [31:0] ARADDR,
    input         ARVALID,
    output        ARREADY,

    //----------------------------------------------------------
    // AXI Read Data Channel
    //----------------------------------------------------------

    output [31:0] RDATA,
    output        RVALID,
    input         RREADY,

    //----------------------------------------------------------
    // Interrupt Output
    //----------------------------------------------------------

    output interrupt

);

    //----------------------------------------------------------
    // Internal Interconnect Signals
    //----------------------------------------------------------

    // Register Bank Write Interface
    wire        write_en;
    wire [31:0] addr;
    wire [31:0] write_data;

    // Register Bank Read Interface
    wire [31:0] read_data;

    // Register Outputs
    wire [31:0] control_reg_out;
    wire [31:0] data_in_reg_out;

    // Hardware Register Updates
    wire [31:0] status_update;
    wire        status_we;

    wire [31:0] data_out_update;
    wire        data_out_we;

    //----------------------------------------------------------
    // AXI-Lite Slave
    //----------------------------------------------------------

    axi_lite_slave u_axi (

        .clk(clk),
        .rst(rst),

        // Write Address
        .AWADDR(AWADDR),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),

        // Write Data
        .WDATA(WDATA),
        .WVALID(WVALID),
        .WREADY(WREADY),

        // Write Response
        .BRESP(BRESP),
        .BVALID(BVALID),
        .BREADY(BREADY),

        // Read Address
        .ARADDR(ARADDR),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),

        // Read Data
        .RDATA(RDATA),
        .RVALID(RVALID),
        .RREADY(RREADY),

        // Register Interface
        .write_en(write_en),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)

    );

    //----------------------------------------------------------
    // Register Bank
    //----------------------------------------------------------

    register_bank u_regbank (

        .clk(clk),
        .rst(rst),

        .write_en(write_en),
        .addr(addr),
        .write_data(write_data),

        .status_update(status_update),
        .status_we(status_we),

        .data_out_update(data_out_update),
        .data_out_we(data_out_we),

        .read_data(read_data),

        .control_reg_out(control_reg_out),
        .data_in_reg_out(data_in_reg_out)

    );

    //----------------------------------------------------------
    // Interrupt Controller
    //----------------------------------------------------------

    interrupt_controller u_intr (

        .clk(clk),
        .rst(rst),

        .control_reg(control_reg_out),
        .data_in_reg(data_in_reg_out),

        .status_update(status_update),
        .status_we(status_we),

        .data_out_update(data_out_update),
        .data_out_we(data_out_we),

        .interrupt(interrupt)

    );

endmodule