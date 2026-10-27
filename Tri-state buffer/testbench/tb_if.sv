

// SystemVerilog Interface for Tri-state Buffer
interface tristate_if;
    logic data_in;      // Input data signal
    logic enable;       // Control/enable signal
    wire  data_out;     // Tri-state output
    
    // Modport for DUT (Design Under Test)
    modport dut (
        input  data_in,
        input  enable,
        output data_out
    );
    
    // Modport for Testbench
    modport tb (
        output data_in,
        output enable,
        input  data_out
    );
    
endinterface


// ========================================
// DESIGN MODULE - Tri-state Buffer (Updated to use Interface)
// ========================================

module tristate_buffer (
    tristate_if.dut bus    // Interface connection
);

    // Tri-state logic implementation
    // When enable = 1: Output follows input data
    // When enable = 0: Output goes to high-impedance (Z) state
    assign bus.data_out = bus.enable ? bus.data_in : 1'bz;

endmodule


// ========================================
// TESTBENCH MODULE (Updated to use Interface)
// Copy this to testbench.sv in EDA Playground (RIGHT panel)
// ========================================

module tristate_buffer_tb;

    // Instantiate the interface
    tristate_if bus();
    
    // Instantiate the Design Under Test (DUT) with interface
    tristate_buffer dut (.bus(bus.dut));
    
    // Test stimulus and verification
    initial begin
        // Setup waveform dump file for viewing
        $dumpfile("dump.vcd");
        $dumpvars(0, tristate_buffer_tb);
        
        // Display test header
        $display("\n========================================");
        $display("   Tri-state Buffer Interface Test      ");
        $display("========================================\n");
        $display("Time\t| Enable | Data_in | Data_out | Status");
        $display("--------|--------|---------|----------|--------");
        
        // Initialize signals through interface
        bus.data_in = 0;
        bus.enable = 0;
        #10;
        
        // TEST CASE 1: Enable=0, Data=0 → Expected: High-Z
        bus.enable = 0; 
        bus.data_in = 0;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | %s", 
                 $time, bus.enable, bus.data_in, bus.data_out,
                 (bus.data_out === 1'bz) ? "PASS" : "FAIL");
        
        // TEST CASE 2: Enable=0, Data=1 → Expected: High-Z
        bus.enable = 0; 
        bus.data_in = 1;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | %s", 
                 $time, bus.enable, bus.data_in, bus.data_out,
                 (bus.data_out === 1'bz) ? "PASS" : "FAIL");
        
        // TEST CASE 3: Enable=1, Data=0 → Expected: 0
        bus.enable = 1; 
        bus.data_in = 0;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | %s", 
                 $time, bus.enable, bus.data_in, bus.data_out,
                 (bus.data_out === 1'b0) ? "PASS" : "FAIL");
        
        // TEST CASE 4: Enable=1, Data=1 → Expected: 1
        bus.enable = 1; 
        bus.data_in = 1;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | %s", 
                 $time, bus.enable, bus.data_in, bus.data_out,
                 (bus.data_out === 1'b1) ? "PASS" : "FAIL");
        
        // Additional Tests: Dynamic Enable Toggle
        $display("\n--- Dynamic Enable Toggle Test ---");
        bus.data_in = 1;
        
        bus.enable = 1;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Enable ON", 
                 $time, bus.enable, bus.data_in, bus.data_out);
        
        bus.enable = 0;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Enable OFF (High-Z)", 
                 $time, bus.enable, bus.data_in, bus.data_out);
        
        bus.enable = 1;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Enable ON", 
                 $time, bus.enable, bus.data_in, bus.data_out);
        
        // Additional Tests: Data Transitions
        $display("\n--- Data Transition Test (Enable=1) ---");
        bus.enable = 1;
        
        bus.data_in = 0;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Data = 0", 
                 $time, bus.enable, bus.data_in, bus.data_out);
        
        bus.data_in = 1;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Data = 1", 
                 $time, bus.enable, bus.data_in, bus.data_out);
        
        bus.data_in = 0;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Data = 0", 
                 $time, bus.enable, bus.data_in, bus.data_out);
        
        bus.data_in = 1;
        #10;
        $display("%0t\t|   %b    |    %b    |    %b     | Data = 1", 
                 $time, bus.enable, bus.data_in, bus.data_out);
        
        // Test completion
        #20;
        $display("\n========================================");
        $display("   All Tests Completed Successfully!    ");
        $display("========================================");
        $display("Waveform saved to dump.vcd");
        $display("Click 'Open EPWave' to view waveforms\n");
        
        $finish;
    end

endmodule