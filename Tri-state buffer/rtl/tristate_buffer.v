
module tristate_buffer (
    input wire data_in,      // Input data signal
    input wire enable,       // Control signal (1=active, 0=high-Z)
    output wire data_out     // Output to shared bus
);

    // Tri-state logic implementation
    // When enable = 1: Output follows input data
    // When enable = 0: Output goes to high-impedance (Z) state
    assign data_out = enable ? data_in : 1'bz;

endmodule