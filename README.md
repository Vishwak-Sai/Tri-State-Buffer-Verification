# Design and Verification of a Tri-State Buffer Using Verilog and SystemVerilog

## 1. Project Overview

This project focuses on the design, simulation, and functional verification of a **Tri-State Buffer** using Verilog HDL and SystemVerilog. A tri-state buffer is a digital circuit that controls data transmission using an enable signal and supports three output states: Logic 0, Logic 1, and High Impedance (Hi-Z).

When the enable signal is HIGH, the output follows the input data. When the enable signal is LOW, the output enters the high-impedance state, effectively disconnecting the buffer output from the shared bus.

The project also explores a modular, transaction-based verification architecture to validate the design's functional behavior through simulation and waveform analysis.

## 2. Objectives

- Design a tri-state buffer using Verilog HDL.
- Verify enable-controlled data propagation and Hi-Z behavior.
- Develop a modular SystemVerilog testbench architecture.
- Compare actual DUT outputs with expected results using a reference model and scoreboard.
- Analyze simulation waveforms to validate functional correctness.

## 3. Design Description

The Tri-State Buffer has two inputs and one output.

| Signal | Direction | Description |
|---|---|---|
| `data` | Input | Data signal supplied to the buffer |
| `en` | Input | Enable signal controlling the buffer |
| `out` | Output | Tri-state output signal |

### Verilog RTL

```verilog
module tristate_buffer (
    input  wire data,
    input  wire en,
    output wire out
);

    assign out = (en) ? data : 1'bz;

endmodule
```

### Truth Table

| Enable (`en`) | Data (`data`) | Output (`out`) |
|---|---|---|
| 0 | 0 | Z |
| 0 | 1 | Z |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

**Key principle:** The output follows the input when enabled and becomes high impedance when disabled.

## 4. Verification Architecture

The project uses a modular SystemVerilog verification environment consisting of the following components:

- **Generator:** Creates input transactions containing data and enable values.
- **Driver:** Applies generated stimulus to the DUT through a virtual interface.
- **Monitor:** Observes input and output signals and captures DUT behavior.
- **Reference Model:** Calculates the expected output based on the input and enable signals.
- **Scoreboard:** Compares the actual DUT output with the expected output and reports mismatches.
- **Environment:** Integrates the verification components and manages their execution.
- **Top Module:** Instantiates the DUT and connects the testbench for simulation.

Mailbox-based communication is used to transfer transactions between verification components.

## 5. Test Scenarios

The testbench applies the following directed test cases:

1. `data = 0, en = 0`: Verify that the output is Z.
2. `data = 1, en = 0`: Verify that the output remains Z.
3. `data = 0, en = 1`: Verify that the output is 0.
4. `data = 1, en = 1`: Verify that the output is 1.
5. `data = 0, en = 0`: Verify the transition back to the high-impedance state.

These scenarios cover all four combinations of the binary input signals.

## 6. Simulation and Results

The design and testbench are simulated to evaluate the functional behavior of the tri-state buffer. The `$monitor`, `$dumpfile`, and `$dumpvars` system tasks are used to observe signal changes and generate waveform data.

The expected results are:

- Correct propagation of input data when the buffer is enabled.
- High-impedance output when the buffer is disabled.
- Correct transitions between driven and high-impedance states.
- Successful comparison of expected and actual outputs when the reference model and scoreboard are integrated.

## 7. Challenges and Solutions

- **Hi-Z verification:** Used the four input combinations to check both enabled and disabled behavior.
- **Testbench integration:** Organized verification into separate components to improve modularity and maintainability.
- **Output validation:** Used a reference model and scoreboard to identify mismatches between expected and observed behavior.
- **Waveform analysis:** Used simulation traces to inspect signal transitions and debug functional issues.

## 8. Applications

Tri-state buffers are useful in:

- Shared data bus architectures.
- Microprocessor and microcontroller interfacing.
- Memory and peripheral interfaces.
- Digital input/output circuits.
- FPGA and ASIC design studies.
- Digital system design and verification education.

**Note:** Internal tri-state logic support varies by FPGA and ASIC technology. FPGA implementations may replace internal tri-state structures with multiplexers.

## 9. Tools and Technologies

- **HDL:** Verilog
- **Verification Language:** SystemVerilog
- **Simulation:** EDA Playground or a compatible Verilog/SystemVerilog simulator
- **Waveform Analysis:** VCD waveform viewer, such as GTKWave
- **Verification Concepts:** Generator, Driver, Monitor, Reference Model, Scoreboard, Mailboxes, Virtual Interfaces

## 10. Future Enhancements

- Add SystemVerilog assertions to check output behavior automatically.
- Implement functional coverage for input and enable combinations.
- Extend the design to a shared bus with multiple tri-state drivers.
- Add automated regression testing and pass/fail reporting.
- Explore synthesis and technology-specific implementation results.

## 11. Learning Outcomes

This project provides practical experience in RTL design, Verilog modeling, SystemVerilog testbench development, transaction-based verification, reference-model checking, scoreboard implementation, and waveform debugging.

It establishes a foundation for further work in **VLSI design, RTL engineering, and functional verification**.

## Author

**Vishwak Sai**

*Interested in VLSI Design, RTL Development, and Design Verification Engineering.*
