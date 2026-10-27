// ========================================
// TEST PROGRAM - test.sv
// Tri-state Buffer Test
// ========================================

program tristate_test(tristate_if vif);
  
  // Environment instance
  tristate_environment env;
  
  // Initial block - main test execution
  initial begin
    // Display test banner
    $display("\n");
    $display("████████████████████████████████████████████████████");
    $display("█                                                  █");
    $display("█     TRI-STATE BUFFER VERIFICATION TEST           █");
    $display("█                                                  █");
    $display("████████████████████████████████████████████████████");
    $display("\n");
    
    // Create environment
    env = new(vif);
    
    // Display configuration
    env.display_config();
    
    // Wait for few clock cycles before starting
    repeat(5) @(posedge vif.clk);
    
    // ==========================================
    // TEST 1: Directed Test - All Combinations
    // ==========================================
    $display("\n");
    $display("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓");
    $display("▓  TEST 1: Directed Test (4 Cases)     ▓");
    $display("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓");
    env.run_directed_test();
    
    // Wait between tests
    repeat(10) @(posedge vif.clk);
    
    // ==========================================
    // TEST 2: Random Test - 20 Transactions
    // ==========================================
    $display("\n");
    $display("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓");
    $display("▓  TEST 2: Random Test (20 Trans)      ▓");
    $display("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓");
    env.run_random_test(20);
    
    // Wait between tests
    repeat(10) @(posedge vif.clk);
    
    // ==========================================
    // TEST 3: Standard Test - 50 Transactions
    // ==========================================
    $display("\n");
    $display("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓");
    $display("▓  TEST 3: Standard Test (50 Trans)    ▓");
    $display("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓");
    env.run_n_transactions(50);
    
    // Wait between tests
    repeat(10) @(posedge vif.clk);
    
    // ==========================================
    // TEST 4: Stress Test - 100 Transactions
    // ==========================================
    $display("\n");
    $display("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓");
    $display("▓  TEST 4: Stress Test (100 Trans)     ▓");
    $display("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓");
    env.run_stress_test(100);
    
    // ==========================================
    // Final Summary
    // ==========================================
    $display("\n");
    $display("████████████████████████████████████████████████████");
    $display("█                                                  █");
    $display("█          VERIFICATION COMPLETE                   █");
    $display("█                                                  █");
    $display("████████████████████████████████████████████████████");
    
    // End simulation
    $display("\n[TEST] Finishing Simulation at time %0t", $time);
    repeat(10) @(posedge vif.clk);
    $finish;
  end
  
  // Timeout watchdog
  initial begin
    #100000; // 100,000 time units timeout
    $display("\n");
    $display("████████████████████████████████████████████████████");
    $display("█                TIMEOUT ERROR                     █");
    $display("█      Simulation exceeded time limit!             █");
    $display("████████████████████████████████████████████████████");
    $finish;
  end

endprogram
