// ========================================
// TRANSACTION CLASS - transaction.sv
// Tri-state Buffer Transaction Definition
// ========================================

class tristate_transaction;
  
  // Randomized input signals
  rand bit data_in;      // Data input (0 or 1)
  rand bit enable;       // Control signal (0=High-Z, 1=Active)
  
  // Output signal (not randomized - driven by DUT)
  logic data_out;        // Output from tri-state buffer
  
  // Transaction ID for tracking
  int trans_id;
  static int trans_count = 0;
  
  // Constraints (optional - for directed testing)
  constraint enable_dist {
    enable dist {0 := 50, 1 := 50};  // Equal probability
  }
  
  constraint data_dist {
    data_in dist {0 := 50, 1 := 50}; // Equal probability
  }
  
  // Constructor
  function new();
    trans_count++;
    trans_id = trans_count;
  endfunction
  
  // Display function for debugging
  function void display(string tag = "TRANSACTION");
    $display("========================================");
    $display("[%s] Transaction #%0d", tag, trans_id);
    $display("Time: %0t", $time);
    $display("Inputs  -> Enable: %0b, Data_in: %0b", enable, data_in);
    $display("Output  -> Data_out: %b", data_out);
    $display("Expected -> %s", enable ? $sformatf("%0b", data_in) : "Z");
    $display("========================================");
  endfunction
  
  // Copy function for transaction duplication
  function tristate_transaction copy();
    tristate_transaction trans = new();
    trans.data_in = this.data_in;
    trans.enable = this.enable;
    trans.data_out = this.data_out;
    return trans;
  endfunction
  
  // Compare function for scoreboard
  function bit compare(tristate_transaction trans);
    if (this.enable !== trans.enable) begin
      $display("[COMPARE ERROR] Enable mismatch: %0b vs %0b", this.enable, trans.enable);
      return 0;
    end
    if (this.data_in !== trans.data_in) begin
      $display("[COMPARE ERROR] Data_in mismatch: %0b vs %0b", this.data_in, trans.data_in);
      return 0;
    end
    // Check output based on enable
    if (this.enable) begin
      if (this.data_out !== trans.data_out) begin
        $display("[COMPARE ERROR] Data_out mismatch: %b vs %b", this.data_out, trans.data_out);
        return 0;
      end
    end
    return 1;
  endfunction
  
  // Check if output is correct
  function bit is_output_correct();
    if (enable) begin
      // When enabled, output should match input
      return (data_out === data_in);
    end else begin
      // When disabled, output should be high-Z
      return (data_out === 1'bz);
    end
  endfunction
  
  // Print transaction in table format
  function void print_table();
    $display("| %4t | %6b | %7b | %8b | %s |",
             $time, enable, data_in, data_out, 
             is_output_correct() ? "PASS" : "FAIL");
  endfunction

endclass