// ========================================
// SCOREBOARD CLASS - scoreboard.sv
// Tri-state Buffer Scoreboard
// ========================================

class tristate_scoreboard;
  
  // Mailbox to receive transactions from monitor
  mailbox #(tristate_transaction) mon2scb;
  
  // Scoreboard statistics
  int num_transactions;
  int num_passed;
  int num_failed;
  
  // Queue to store transactions for analysis
  tristate_transaction trans_queue[$];
  
  // Constructor
  function new(mailbox #(tristate_transaction) mon2scb);
    this.mon2scb = mon2scb;
    this.num_transactions = 0;
    this.num_passed = 0;
    this.num_failed = 0;
  endfunction
  
  // Main scoreboard task
  task run();
    tristate_transaction trans;
    
    $display("========================================");
    $display("[SCOREBOARD] Starting Scoreboard");
    $display("========================================");
    
    forever begin
      // Get transaction from monitor
      mon2scb.get(trans);
      
      // Check the transaction
      check_transaction(trans);
      
      // Store transaction in queue for history
      trans_queue.push_back(trans.copy());
    end
  endtask
  
  // Task to check a single transaction
  task check_transaction(tristate_transaction trans);
    bit result;
    logic expected_output;
    
    num_transactions++;
    
    // Calculate expected output
    if (trans.enable) begin
      expected_output = trans.data_in;
    end else begin
      expected_output = 1'bz;
    end
    
    // Compare actual vs expected
    if (trans.enable) begin
      // When enabled, check if output matches input
      if (trans.data_out === trans.data_in) begin
        result = 1;
        num_passed++;
        $display("[SCOREBOARD] Transaction #%0d -> PASS", num_transactions);
        $display("             Enable=%0b, Data_in=%0b, Data_out=%b (Expected: %0b)",
                 trans.enable, trans.data_in, trans.data_out, expected_output);
      end else begin
        result = 0;
        num_failed++;
        $display("[SCOREBOARD] Transaction #%0d -> FAIL", num_transactions);
        $display("             Enable=%0b, Data_in=%0b, Data_out=%b (Expected: %0b)",
                 trans.enable, trans.data_in, trans.data_out, expected_output);
      end
    end else begin
      // When disabled, check if output is high-Z
      if (trans.data_out === 1'bz) begin
        result = 1;
        num_passed++;
        $display("[SCOREBOARD] Transaction #%0d -> PASS", num_transactions);
        $display("             Enable=%0b, Data_in=%0b, Data_out=%b (Expected: Z)",
                 trans.enable, trans.data_in, trans.data_out);
      end else begin
        result = 0;
        num_failed++;
        $display("[SCOREBOARD] Transaction #%0d -> FAIL", num_transactions);
        $display("             Enable=%0b, Data_in=%0b, Data_out=%b (Expected: Z)",
                 trans.enable, trans.data_in, trans.data_out);
      end
    end
  endtask
  
  // Check specific number of transactions
  task check_n_transactions(int n);
    tristate_transaction trans;
    
    $display("[SCOREBOARD] Checking %0d transactions", n);
    
    repeat(n) begin
      mon2scb.get(trans);
      check_transaction(trans);
      trans_queue.push_back(trans.copy());
    end
    
    $display("[SCOREBOARD] Completed checking %0d transactions", n);
  endtask
  
  // Display detailed results in table format
  task display_results();
    $display("\n========================================");
    $display("  SCOREBOARD - Detailed Results");
    $display("========================================");
    $display("| Trans# | Enable | Data_in | Data_out | Expected | Result |");
    $display("|--------|--------|---------|----------|----------|--------|");
    
    foreach(trans_queue[i]) begin
      logic expected;
      string result_str;
      
      if (trans_queue[i].enable)
        expected = trans_queue[i].data_in;
      else
        expected = 1'bz;
      
      result_str = trans_queue[i].is_output_correct() ? "PASS" : "FAIL";
      
      $display("| %6d | %6b | %7b | %8b | %8b | %6s |",
               i+1, trans_queue[i].enable, trans_queue[i].data_in, 
               trans_queue[i].data_out, expected, result_str);
    end
    
    $display("========================================");
  endtask
  
  // Display final statistics
  function void display_stats();
    real pass_rate;
    
    $display("\n========================================");
    $display("[SCOREBOARD] Final Statistics");
    $display("========================================");
    $display("Total Transactions Checked: %0d", num_transactions);
    $display("Passed: %0d", num_passed);
    $display("Failed: %0d", num_failed);
    
    if (num_transactions > 0) begin
      pass_rate = (real'(num_passed) / real'(num_transactions)) * 100.0;
      $display("Pass Rate: %.2f%%", pass_rate);
      
      if (num_failed == 0)
        $display("✓ ALL TESTS PASSED!");
      else
        $display("✗ SOME TESTS FAILED!");
    end else begin
      $display("No transactions checked yet.");
    end
    
    $display("========================================");
  endfunction
  
  // Check if all tests passed
  function bit all_tests_passed();
    return (num_failed == 0 && num_transactions > 0);
  endfunction
  
  // Get pass rate
  function real get_pass_rate();
    if (num_transactions > 0)
      return (real'(num_passed) / real'(num_transactions)) * 100.0;
    else
      return 0.0;
  endfunction
  
  // Reset scoreboard
  function void reset();
    num_transactions = 0;
    num_passed = 0;
    num_failed = 0;
    trans_queue.delete();
    $display("[SCOREBOARD] Scoreboard Reset");
  endfunction
  
  // Display summary report
  function void display_summary();
    $display("\n");
    $display("╔════════════════════════════════════════╗");
    $display("║    SCOREBOARD SUMMARY REPORT           ║");
    $display("╔════════════════════════════════════════╗");
    $display("║ Total Transactions : %-17d║", num_transactions);
    $display("║ Passed             : %-17d║", num_passed);
    $display("║ Failed             : %-17d║", num_failed);
    $display("║ Pass Rate          : %5.2f%%           ║", get_pass_rate());
    $display("╚════════════════════════════════════════╝");
    
    if (all_tests_passed())
      $display("║          ALL TESTS PASSED!            ║");
    else
      $display("║          SOME TESTS FAILED!           ║");
    
    $display("╚════════════════════════════════════════╝\n");
  endfunction

endclass