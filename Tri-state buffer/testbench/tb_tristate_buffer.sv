// ========================================
// TESTBENCH CODE - Tri-state Buffer
// Copy this ENTIRE code to testbench.sv in EDA Playground (RIGHT panel)
// ========================================

module tristate_buffer_tb;

    // Declare testbench signals
    reg data_in;
    reg enable;
    wire data_out;
    
    // Instantiate the Design Under Test (DUT)
    tristate_buffer dut (
        .data_in(data_in),
        .enable(enable),
        .data_out(data_out)
    );
    
    // Test stimulus and verification
    initial begin
        // Setup waveform dump file for viewing
        $dumpfile("dump.vcd");
        $dumpvars(0, tristate_buffer_tb);
        
        // Display test header
        $display("\n========================================");
        $display("   Tri-state Buffer Verification Test   ");
        $display("========================================\n");
        $display("Time\t| Enable | Data_in | Data_out | Status");
        $display("--------|--------|---------|----------|--------");
        
        // Initialize signals
        data_in = 0;
        enable = 0;
        #10;
        
        // TEST CASE 1: Enable=0, Data=0 → Expected: High-Z
        enable = 0; 
        data_in = 0;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | %s", 
                 $time, enable, data_in, data_out,
                 (data_out === 1'bz) ? "PASS" : "FAIL");
        
        // TEST CASE 2: Enable=0, Data=1 → Expected: High-Z
        enable = 0; 
        data_in = 1;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | %s", 
                 $time, enable, data_in, data_out,
                 (data_out === 1'bz) ? "PASS" : "FAIL");
        
        // TEST CASE 3: Enable=1, Data=0 → Expected: 0
        enable = 1; 
        data_in = 0;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | %s", 
                 $time, enable, data_in, data_out,
                 (data_out === 1'b0) ? "PASS" : "FAIL");
        
        // TEST CASE 4: Enable=1, Data=1 → Expected: 1
        enable = 1; 
        data_in = 1;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | %s", 
                 $time, enable, data_in, data_out,
                 (data_out === 1'b1) ? "PASS" : "FAIL");
        
        // Additional Tests: Dynamic Enable Toggle
        $display("\n--- Dynamic Enable Toggle Test ---");
        data_in = 1;
        
        enable = 1;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Enable ON", 
                 $time, enable, data_in, data_out);
        
        enable = 0;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Enable OFF (High-Z)", 
                 $time, enable, data_in, data_out);
        
        enable = 1;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Enable ON", 
                 $time, enable, data_in, data_out);
        
        // Additional Tests: Data Transitions
        $display("\n--- Data Transition Test (Enable=1) ---");
        enable = 1;
        
        data_in = 0;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Data = 0", 
                 $time, enable, data_in, data_out);
        
        data_in = 1;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Data = 1", 
                 $time, enable, data_in, data_out);
        
        data_in = 0;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Data = 0", 
                 $time, enable, data_in, data_out);
        
        data_in = 1;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Data = 1", 
                 $time, enable, data_in, data_out);
        
        // Test completion
        #20;
        $display("\n========================================");
        $display("   All Tests Completed Successfully!    ");
        $display("========================================");
        $display("\nWaveform saved to dump.vcd");
        $display("Click 'Open EPWave' to view waveforms\n");
        
        $finish;
    end

endmodule