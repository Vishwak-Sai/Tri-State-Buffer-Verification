// ========================================
// ENVIRONMENT CLASS - env.sv
// Tri-state Buffer Environment
// ========================================

class tristate_environment;
  
  // Virtual interface handle
  virtual tristate_if vif;
  
  // Mailbox declarations
  mailbox #(tristate_transaction) gen2drv;
  mailbox #(tristate_transaction) mon2scb;
  
  // Component instances
  tristate_generator gen;
  tristate_driver drv;
  tristate_monitor mon;
  tristate_scoreboard scb;
  
  // Configuration
  int num_transactions = 10;  // Default number of transactions
  
  // Constructor
  function new(virtual tristate_if vif);
    this.vif = vif;
    
    // Create mailboxes
    gen2drv = new();
    mon2scb = new();
    
    // Create components
    gen = new(gen2drv);
    drv = new(vif, gen2drv);
    mon = new(vif, mon2scb);
    scb = new(mon2scb);
    
    $display("========================================");
    $display("[ENVIRONMENT] Environment Created");
    $display("========================================");
  endfunction
  
  // Pre-test: Initialize environment
  task pre_test();
    $display("\n========================================");
    $display("[ENVIRONMENT] Pre-Test Phase");
    $display("========================================");
    
    // Apply reset
    drv.reset();
    
    $display("[ENVIRONMENT] Pre-Test Complete");
  endtask
  
  // Test: Run the main test
  task test();
    $display("\n========================================");
    $display("[ENVIRONMENT] Test Phase Started");
    $display("========================================");
    
    // Fork all components to run in parallel
    fork
      gen.run();              // Generator creates transactions
      drv.run();              // Driver drives transactions to DUT
      mon.run();              // Monitor observes DUT outputs
      scb.run();              // Scoreboard checks correctness
    join_any
    
    // Wait for all transactions to complete
    wait(gen.trans_count == num_transactions);
    
    // Small delay to let remaining transactions finish
    repeat(10) @(posedge vif.clk);
    
    $display("[ENVIRONMENT] Test Phase Complete");
  endtask
  
  // Post-test: Collect results and display statistics
  task post_test();
    $display("\n========================================");
    $display("[ENVIRONMENT] Post-Test Phase");
    $display("========================================");
    
    // Wait for pipeline to drain
    repeat(5) @(posedge vif.clk);
    
    // Display statistics from all components
    $display("\n--- Generator Statistics ---");
    gen.display_stats();
    
    $display("\n--- Driver Statistics ---");
    drv.display_stats();
    
    $display("\n--- Monitor Statistics ---");
    mon.display_stats();
    
    $display("\n--- Scoreboard Statistics ---");
    scb.display_summary();
    
    // Final result
    if (scb.all_tests_passed()) begin
      $display("\n");
      $display("╔════════════════════════════════════════╗");
      $display("║   ✓✓✓ ALL TESTS PASSED! ✓✓✓           ║");
      $display("╚════════════════════════════════════════╝");
    end else begin
      $display("\n");
      $display("╔════════════════════════════════════════╗");
      $display("║   ✗✗✗ SOME TESTS FAILED! ✗✗✗          ║");
      $display("╚════════════════════════════════════════╝");
    end
    
    $display("\n[ENVIRONMENT] Post-Test Complete");
  endtask
  
  // Main run task - executes complete test flow
  task run();
    $display("\n");
    $display("╔════════════════════════════════════════╗");
    $display("║  TRI-STATE BUFFER VERIFICATION ENV     ║");
    $display("╚════════════════════════════════════════╝");
    $display("[ENVIRONMENT] Starting Verification with %0d transactions", num_transactions);
    
    // Set number of transactions in generator
    gen.num_transactions = num_transactions;
    
    // Execute test phases
    pre_test();
    test();
    post_test();
    
    $display("\n[ENVIRONMENT] Verification Complete");
    $display("========================================\n");
  endtask
  
  // Run with custom number of transactions
  task run_n_transactions(int n);
    num_transactions = n;
    $display("[ENVIRONMENT] Configured for %0d transactions", n);
    run();
  endtask
  
  // Run directed test - all combinations
  task run_directed_test();
    $display("\n========================================");
    $display("[ENVIRONMENT] Running Directed Test");
    $display("========================================");
    
    // Apply reset
    drv.reset();
    
    // Fork monitor and scoreboard
    fork
      mon.monitor_n_transactions(4);
      scb.check_n_transactions(4);
    join_none
    
    // Drive all combinations
    drv.drive_all_combinations();
    
    // Wait for completion
    repeat(10) @(posedge vif.clk);
    
    // Display results
    scb.display_summary();
    
    $display("[ENVIRONMENT] Directed Test Complete");
  endtask
  
  // Run random test
  task run_random_test(int n = 20);
    $display("\n========================================");
    $display("[ENVIRONMENT] Running Random Test (%0d transactions)", n);
    $display("========================================");
    
    num_transactions = n;
    gen.num_transactions = n;
    
    run();
  endtask
  
  // Run stress test - many transactions
  task run_stress_test(int n = 1000);
    $display("\n========================================");
    $display("[ENVIRONMENT] Running Stress Test (%0d transactions)", n);
    $display("========================================");
    
    num_transactions = n;
    gen.num_transactions = n;
    
    run();
  endtask
  
  // Display environment configuration
  function void display_config();
    $display("\n========================================");
    $display("[ENVIRONMENT] Configuration");
    $display("========================================");
    $display("Number of Transactions: %0d", num_transactions);
    $display("Generator: %s", gen == null ? "Not Created" : "Ready");
    $display("Driver: %s", drv == null ? "Not Created" : "Ready");
    $display("Monitor: %s", mon == null ? "Not Created" : "Ready");
    $display("Scoreboard: %s", scb == null ? "Not Created" : "Ready");
    $display("========================================");
  endfunction

endclass