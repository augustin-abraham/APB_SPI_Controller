# APB-Based SPI Controller using Verilog HDL

Designed and simulated an APB-based SPI controller using Verilog HDL for serial communication and peripheral interfacing applications.

---

## Project Overview

This project implements an APB-based SPI communication controller with modular RTL architecture. The design includes APB interfacing, SPI control logic, FIFO buffering, baud rate generation, and shift register operations.

The project was functionally verified using ModelSim with individual testbenches for all RTL modules.

---

## Features

- APB Slave Interface
- SPI Communication Protocol
- FIFO Buffering
- Baud Rate Generator
- Shift Register Implementation
- FSM-Based Control Logic
- Modular RTL Design
- Functional Verification using Testbenches

---

## RTL Modules

### APB Slave Interface
Handles APB read/write transactions and control signal generation.

### SPI Slave Control Select
Implements SPI control FSM and slave selection logic.

### FIFO
Provides temporary storage and buffering for data transfer.

### Shift Register
Handles serial-to-parallel and parallel-to-serial data conversion.

### Baud Rate Generator
Generates clock timing required for SPI communication.

### SPI Top Module
Integrates all SPI-related submodules into a complete controller.

---

## Verification

- Functional verification completed using ModelSim
- Individual testbenches created for all RTL modules
- Waveform analysis performed for protocol validation

---

## Tools Used

- Verilog HDL
- ModelSim

---

## Folder Structure

```text
APB_SPI_Controller/
│
├── rtl/          → RTL source files
├── tb/           → Testbench files
├── waveforms/    → Simulation waveform screenshots
├── docs/         → Block diagrams and documentation
└── README.md
```

---

## Future Improvements

- SystemVerilog-based verification
- UVM Testbench Integration
- Interrupt support
- Enhanced FIFO functionality
- FPGA implementation

---

## Author

Augustin C Abraham  
MSc Electronics  
Embedded Systems and Semiconductor Enthusiast
