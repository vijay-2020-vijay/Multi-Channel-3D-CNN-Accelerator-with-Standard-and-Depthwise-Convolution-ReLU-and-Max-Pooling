`timescale 1ns / 1ps     
   
module testbench;  
    // Parameters
    parameter n  = 256;
    parameter n_t=65536;//n*n
    parameter k  = 3;
    parameter ch  = 3;
    parameter MA = 18;
    parameter fi =1;
    parameter DEPTH = 2**MA;

    // Clock and reset
    reg clk;
    reg reset;

    // Base addresses
    reg [MA-1:0] kbase_address;
    reg [MA-1:0] ibase_address;
    reg [MA-1:0] maxpoo1_store_address;

    // Outputs from CNN
    wire karnel_complete;
    wire image_row_complete;
    wire con_rellu_complete;
    wire image_row_pool_complete;

    // Instantiate CNN Accelerator (it already has BRAM inside)
    CNN_Accleretor #(n,n_t,k,ch,fi,MA, DEPTH) uut (
        .clk(clk),
        .reset(reset),
        .kbase_address(kbase_address),
        .ibase_address(ibase_address),
        .maxpoo1_store_address(maxpoo1_store_address),
        .karnel_complete(karnel_complete),
        .image_row_complete(image_row_complete),
        .con_rellu_complete(con_rellu_complete),
        .image_row_pool_complete(image_row_pool_complete)
    );

    // Clock generation (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // File I/O
      integer f, i;

    // -------------------------------
    // Test procedure
    // -------------------------------
    initial begin
        // Apply reset
        reset = 1;
        kbase_address = 18'd0;           // kernel base
        ibase_address = 18'd9;            // image base
        maxpoo1_store_address = 18'd200000;  // pooled results base
        #50;
        reset = 0;

        // Run simulation until CNN finishes
        #6967000;
        
                // Open file to dump BRAM contents
        f = $fopen("D:/memorey test file for cnn_accleretor/bram_dump6.txt", "w");
        if (f == 0) begin
            $display("ERROR: Cannot open file!");
            $stop;
        end

        // Read memory directly from uut's internal BRAM instance
        // NOTE: hierarchical reference into uut.bram_inst.mem
        for (i = 14; i < 65038; i = i + 1) begin
            //$fwrite(f, "Address %0d : Data = %d\n", i, uut.bram_inst.mem[i]);
          $fwrite(f,"%d\n",uut.bram_inst.mem[i]);
        end

        $fclose(f);
        $display("BRAM dump completed.");
        $stop;

        
        end
endmodule

