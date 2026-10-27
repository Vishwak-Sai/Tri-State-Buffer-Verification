// ========================================
// DRIVER CLASS - driver.sv
// Tri-state Buffer Driver
// ========================================

class tristate_driver;
  
  // Virtual interface handle
  virtual tristate_if vif;
  
  // Mailbox to receive transactions from generator
  mailbox #(tristate_transaction) gen2drv;
  
  // Event to signal completion
  event drv_done;
  
  // Driver configuration
  int num_transactions;
  
  // Constructor
  function new(virtual tristate_if vif, mailbox #(tristate_transaction) gen2drv);
    this.vif = vif;
    this.gen2drv = gen2drv;
    this.num_transactions = 0;
  endfunction
  
  // Reset task
  task reset();
    $display("[DRIVER] Applying Reset at time %0t", $time);
    vif.enable <= 0;
    vif.data_in <= 0;
    repeat(2) @(posedge vif.clk);
    $display("[DRIVER] Reset Complete at time %0t", $time);
  endtask
  
  // Main driver task
  task run();
    tristate_transaction trans;
    
    $display("========================================");
    $display("[DRIVER] Starting Driver");
    $display("========================================");
    
    // Apply reset first
    reset();
    
    forever begin
      // Get transaction from mailbox
      gen2drv.get(trans);
      num_transactions++;
      
      $display("[DRIVER] Driving Transaction #%0d at time %0t", num_transactions, $time);
      
      // Drive the transaction to DUT
      drive_transaction(trans);
      
      // Signal completion
      ->drv_done;
    end
  endtask
  
  // Task to drive a single transaction
  task drive_transaction(tristate_transaction trans);
    // Wait for clock edge
    @(posedge vif.clk);
    
    // Drive inputs to interface
    vif.enable <= trans.enable;
    vif.data_in <= trans.data_in;
    
    $display("[DRIVER] Driven -> Enable: %0b, Data_in: %0b", trans.enable, trans.data_in);
    
    // Hold for one clock cycle
    @(posedge vif.clk);
    
    // Small delay for signal propagation
    #1;
  endtask
  
  // Task to drive specific test scenario
  task drive_custom(bit en, bit data);
    tristate_transaction trans = new();
    trans.enable = en;
    trans.data_in = data;
    
    $display("[DRIVER] Custom Drive -> Enable: %0b, Data_in: %0b", en, data);
    drive_transaction(trans);
  endtask
  
  // Task to drive all combinations
  task drive_all_combinations();
    $display("[DRIVER] Driving All Input Combinations");
    
    // Test case 1: enable=0, data=0
    drive_custom(0, 0);
    
    // Test case 2: enable=0, data=1
    drive_custom(0, 1);
    
    // Test case 3: enable=1, data=0
    drive_custom(1, 0);
    
    // Test case 4: enable=1, data=1
    drive_custom(1, 1);
    
    $display("[DRIVER] All Combinations Driven");
  endtask
  
  // Display driver statistics
  function void display_stats();
    $display("========================================");
    $display("[DRIVER] Statistics");
    $display("Total Transactions Driven: %0d", num_transactions);
    $display("========================================");
  endfunction

endclass