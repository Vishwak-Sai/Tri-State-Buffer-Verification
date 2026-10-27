// ========================================
// MONITOR CLASS - monitor.sv
// Tri-state Buffer Monitor
// ========================================

class tristate_monitor;
  
  // Virtual interface handle
  virtual tristate_if vif;
  
  // Mailbox to send transactions to scoreboard
  mailbox #(tristate_transaction) mon2scb;
  
  // Event to signal monitoring completion
  event mon_done;
  
  // Monitor statistics
  int num_transactions;
  int num_pass;
  int num_fail;
  
  // Constructor
  function new(virtual tristate_if vif, mailbox #(tristate_transaction) mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
    this.num_transactions = 0;
    this.num_pass = 0;
    this.num_fail = 0;
  endfunction
  
  // Main monitor task
  task run();
    tristate_transaction trans;
    
    $display("========================================");
    $display("[MONITOR] Starting Monitor");
    $display("========================================");
    
    forever begin
      // Create new transaction
      trans = new();
      
      // Sample the interface signals
      sample_transaction(trans);
      
      // Increment transaction count
      num_transactions++;
      
      // Check if output is correct
      if (trans.is_output_correct()) begin
        num_pass++;
        $display("[MONITOR] Transaction #%0d -> PASS", num_transactions);
      end else begin
        num_fail++;
        $display("[MONITOR] Transaction #%0d -> FAIL", num_transactions);
      end
      
      // Send transaction to scoreboard
      mon2scb.put(trans);
      
      // Display monitored transaction
      $display("[MONITOR] Captured -> Enable: %0b, Data_in: %0b, Data_out: %b at time %0t", 
               trans.enable, trans.data_in, trans.data_out, $time);
      
      // Signal completion
      ->mon_done;
    end
  endtask
  
  // Task to sample signals from interface
  task sample_transaction(tristate_transaction trans);
    // Wait for clock edge
    @(posedge vif.clk);
    
    // Small delay for signal stabilization
    #1;
    
    // Sample inputs
    trans.enable = vif.enable;
    trans.data_in = vif.data_in;
    
    // Sample output
    trans.data_out = vif.data_out;
  endtask
  
  // Task to continuously monitor and display
  task monitor_and_display();
    tristate_transaction trans;
    
    $display("\n========================================");
    $display("  Continuous Monitoring Started");
    $display("========================================");
    $display("| Time | Enable | Data_in | Data_out | Status |");
    $display("|------|--------|---------|----------|--------|");
    
    forever begin
      trans = new();
      sample_transaction(trans);
      trans.print_table();
      
      if (trans.is_output_correct())
        num_pass++;
      else
        num_fail++;
        
      num_transactions++;
      mon2scb.put(trans);
    end
  endtask
  
  // Monitor specific number of transactions
  task monitor_n_transactions(int n);
    tristate_transaction trans;
    
    $display("[MONITOR] Monitoring %0d transactions", n);
    
    repeat(n) begin
      trans = new();
      sample_transaction(trans);
      
      num_transactions++;
      
      if (trans.is_output_correct())
        num_pass++;
      else
        num_fail++;
      
      mon2scb.put(trans);
      
      $display("[MONITOR] Transaction #%0d -> Enable: %0b, Data_in: %0b, Data_out: %b [%s]",
               num_transactions, trans.enable, trans.data_in, trans.data_out,
               trans.is_output_correct() ? "PASS" : "FAIL");
    end
    
    $display("[MONITOR] Completed monitoring %0d transactions", n);
  endtask
  
  // Peek at current interface values without sampling
  function void peek_interface();
    $display("[MONITOR] Current Interface Values at time %0t:", $time);
    $display("  Enable: %0b", vif.enable);
    $display("  Data_in: %0b", vif.data_in);
    $display("  Data_out: %b", vif.data_out);
  endfunction
  
  // Display monitor statistics
  function void display_stats();
    real pass_rate;
    
    $display("\n========================================");
    $display("[MONITOR] Final Statistics");
    $display("========================================");
    $display("Total Transactions Monitored: %0d", num_transactions);
    $display("Passed: %0d", num_pass);
    $display("Failed: %0d", num_fail);
    
    if (num_transactions > 0) begin
      pass_rate = (real'(num_pass) / real'(num_transactions)) * 100.0;
      $display("Pass Rate: %.2f%%", pass_rate);
    end
    
    $display("========================================");
  endfunction
  
  // Reset statistics
  function void reset_stats();
    num_transactions = 0;
    num_pass = 0;
    num_fail = 0;
    $display("[MONITOR] Statistics Reset");
  endfunction

endclass