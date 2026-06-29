`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company        : Student Project
// Engineer       : Your Name
//
// Design Name    : BusBridge - AXI-Lite Peripheral IP
// Module Name    : tb_axi_lite
// Project        : VLSI Internship Project
//
// Description:
// Professional self-checking testbench for the AXI-Lite Peripheral.
//
// Test Flow:
// 1. Apply Reset
// 2. Write DATA_IN Register
// 3. Read DATA_IN Register
// 4. Start Processing
// 5. Wait for Processing Completion
// 6. Read STATUS Register
// 7. Read DATA_OUT Register
// 8. Verify Results Automatically
//////////////////////////////////////////////////////////////////////////////////

module tb_axi_lite;

    //----------------------------------------------------------
    // Clock and Reset
    //----------------------------------------------------------

    reg clk;
    reg rst;

    //----------------------------------------------------------
    // AXI Write Address Channel
    //----------------------------------------------------------

    reg  [31:0] AWADDR;
    reg         AWVALID;
    wire        AWREADY;

    //----------------------------------------------------------
    // AXI Write Data Channel
    //----------------------------------------------------------

    reg  [31:0] WDATA;
    reg         WVALID;
    wire        WREADY;

    //----------------------------------------------------------
    // AXI Write Response Channel
    //----------------------------------------------------------

    wire [1:0] BRESP;
    wire       BVALID;
    reg        BREADY;

    //----------------------------------------------------------
    // AXI Read Address Channel
    //----------------------------------------------------------

    reg  [31:0] ARADDR;
    reg         ARVALID;
    wire        ARREADY;

    //----------------------------------------------------------
    // AXI Read Data Channel
    //----------------------------------------------------------

    wire [31:0] RDATA;
    wire        RVALID;
    reg         RREADY;

    //----------------------------------------------------------
    // Interrupt
    //----------------------------------------------------------

    wire interrupt;

    //----------------------------------------------------------
    // Register Address Map
    //----------------------------------------------------------

    localparam CONTROL_ADDR  = 32'h00000000;
    localparam STATUS_ADDR   = 32'h00000004;
    localparam DATA_IN_ADDR  = 32'h00000008;
    localparam DATA_OUT_ADDR = 32'h0000000C;

    //----------------------------------------------------------
    // Verification Statistics
    //----------------------------------------------------------

    integer pass_count;
    integer fail_count;

    //----------------------------------------------------------
    // Device Under Test (DUT)
    //----------------------------------------------------------

    top dut(

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

        // Interrupt
        .interrupt(interrupt)

    );

    //----------------------------------------------------------
    // Clock Generation
    // 100 MHz Clock (10 ns Period)
    //----------------------------------------------------------

    initial
        clk = 1'b0;

    always
        #5 clk = ~clk;
    
        //----------------------------------------------------------
    // AXI Write Task
    // Performs one AXI-Lite write transaction
    //----------------------------------------------------------
    task axi_write;

        input [31:0] address;
        input [31:0] data;

        begin

            // Drive address and data
            @(posedge clk);

            AWADDR  <= address;
            AWVALID <= 1'b1;

            WDATA   <= data;
            WVALID  <= 1'b1;

            // Wait one clock cycle for transfer
            @(posedge clk);

            AWVALID <= 1'b0;
            WVALID  <= 1'b0;

            // Accept write response
            BREADY <= 1'b1;

            wait(BVALID);

            @(posedge clk);

            BREADY <= 1'b0;

            $display("--------------------------------------------");
            $display("[WRITE]");
            $display("Time    : %0t", $time);
            $display("Address : 0x%08h", address);
            $display("Data    : %0d", data);
            $display("--------------------------------------------");

        end

    endtask


    //----------------------------------------------------------
    // AXI Read Task
    // Performs one AXI-Lite read transaction
    //----------------------------------------------------------
    task axi_read;

        input [31:0] address;

        begin

            @(posedge clk);

            ARADDR  <= address;
            ARVALID <= 1'b1;

            @(posedge clk);

            ARVALID <= 1'b0;

            RREADY <= 1'b1;

            // Wait until slave returns valid data
            wait(RVALID);

            @(posedge clk);

            $display("--------------------------------------------");
            $display("[READ]");
            $display("Time    : %0t", $time);
            $display("Address : 0x%08h", address);
            $display("Data    : %0d", RDATA);
            $display("--------------------------------------------");

            RREADY <= 1'b0;

        end

    endtask

        //----------------------------------------------------------
    // Task : Check Register Value
    // Compares actual data with expected data
    //----------------------------------------------------------
    task check_register;

        input [31:0] expected;

        begin

            if (RDATA === expected) begin

                $display("============================================");
                $display("PASS");
                $display("Expected : %0d", expected);
                $display("Received : %0d", RDATA);
                $display("============================================");

                pass_count = pass_count + 1;

            end
            else begin

                $display("============================================");
                $display("FAIL");
                $display("Expected : %0d", expected);
                $display("Received : %0d", RDATA);
                $display("============================================");

                fail_count = fail_count + 1;

            end

        end

    endtask


    //----------------------------------------------------------
    // Task : Run Complete Processing Test
    //----------------------------------------------------------
    task run_test;

        input [31:0] input_data;
        input [31:0] expected_output;

        begin

            $display("");
            $display("#################################################");
            $display("Running Test");
            $display("Input Data      = %0d", input_data);
            $display("Expected Output = %0d", expected_output);
            $display("#################################################");

            //--------------------------------------------------
            // Write DATA_IN Register
            //--------------------------------------------------

            axi_write(DATA_IN_ADDR, input_data);

            //--------------------------------------------------
            // Verify DATA_IN Register
            //--------------------------------------------------

            axi_read(DATA_IN_ADDR);
            check_register(input_data);

            //--------------------------------------------------
            // Start Processing
            //--------------------------------------------------

            axi_write(CONTROL_ADDR, 32'd1);

            //--------------------------------------------------
            // Wait for FSM to Finish
            //--------------------------------------------------

            wait(interrupt == 1'b1);

            @(posedge clk);

            //--------------------------------------------------
            // Verify STATUS Register
            //--------------------------------------------------

            axi_read(STATUS_ADDR);
            check_register(32'd1);

            //--------------------------------------------------
            // Verify DATA_OUT Register
            //--------------------------------------------------

            axi_read(DATA_OUT_ADDR);
            check_register(expected_output);

            //--------------------------------------------------
            // Clear CONTROL Register
            //--------------------------------------------------

            axi_write(CONTROL_ADDR, 32'd0);

            //--------------------------------------------------
            // Wait for Interrupt to Clear
            //--------------------------------------------------

            wait(interrupt == 1'b0);

            @(posedge clk);

            $display("Test Completed Successfully.");
            $display("");

        end

    endtask

        //----------------------------------------------------------
    // Main Test Sequence
    //----------------------------------------------------------
    initial begin

        //------------------------------------------------------
        // Initialize Signals
        //------------------------------------------------------

        clk = 1'b0;
        rst = 1'b1;

        AWADDR  = 32'd0;
        AWVALID = 1'b0;

        WDATA   = 32'd0;
        WVALID  = 1'b0;

        BREADY  = 1'b0;

        ARADDR  = 32'd0;
        ARVALID = 1'b0;

        RREADY  = 1'b0;

        pass_count = 0;
        fail_count = 0;

        //------------------------------------------------------
        // Simulation Banner
        //------------------------------------------------------

        $display("");
        $display("====================================================");
        $display("        BUSBRIDGE AXI-LITE IP VERIFICATION");
        $display("====================================================");

        //------------------------------------------------------
        // Apply Reset
        //------------------------------------------------------

        #20;
        rst = 1'b0;

        @(posedge clk);

        $display("");
        $display("Reset Released Successfully");
        $display("");

        //------------------------------------------------------
        // Execute Test Cases
        //------------------------------------------------------

        run_test(0,0);

        run_test(1,2);

        run_test(25,50);

        run_test(100,200);

        run_test(255,510);

        //------------------------------------------------------
        // Final Summary
        //------------------------------------------------------

        $display("");
        $display("====================================================");
        $display("              VERIFICATION SUMMARY");
        $display("====================================================");

        $display("Total PASS Checks : %0d", pass_count);
        $display("Total FAIL Checks : %0d", fail_count);

        if(fail_count == 0)
        begin
            $display("");
            $display("ALL TEST CASES PASSED");
            $display("Peripheral IP Verified Successfully");
        end
        else
        begin
            $display("");
            $display("Some Test Cases Failed");
            $display("Please Debug the RTL");
        end

        $display("====================================================");

        #20;

        $finish;

    end

endmodule