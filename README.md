# BusBridge - AXI4-Lite Peripheral IP

## Overview

BusBridge is a simple AXI4-Lite Peripheral IP developed in Verilog HDL as part of an internship project. The project demonstrates the implementation of an AXI4-Lite Slave Interface, Register Bank, Interrupt Controller, and Functional Verification using a Verilog testbench.

The design was created and simulated using **Xilinx Vivado**.

---

## Features

- AXI4-Lite Slave Interface
- Memory-Mapped Register Bank
- Interrupt Controller using FSM
- Read and Write Transactions
- Register-Based Communication
- Functional Verification using Verilog Testbench
- Synthesizable RTL Design

---

## Project Structure

```
BusBridge/
│
├── rtl/
│   ├── axi_lite_slave.v
│   ├── interrupt_controller.v
│   ├── register_bank.v
│   └── top.v
│
├── sim_docs/
│   ├── rtl_block_diagram.png
|   ├── rtl_schematic.png
|   ├── waveform.png
│
├── synthesis/
│   ├── error_report.png
|   ├── timing_summary.png
|   ├── utilization_report.png
│
├── tb/
|   ├── tb_axi_lite.v
│
└── README.md
```

---

## Register Map

| Address  | Register |   Access   |
|----------|----------|------------|
| 0x00     | CONTROL  | Read/Write |
| 0x04     | STATUS   | Read Only  |
| 0x08     | DATA_IN  | Read/Write |
| 0x0C     | DATA_OUT | Read Only  |

---

## Processing Flow

1. Write input data to the DATA_IN register.
2. Write `1` to the CONTROL register to start processing.
3. The Interrupt Controller processes the data.
4. The processed result is stored in the DATA_OUT register.
5. The STATUS register is updated.
6. An interrupt is generated to indicate completion.

---

## Simulation

The design was verified using a Verilog testbench in Xilinx Vivado.

The following operations were tested:

- Reset
- Register Write
- Register Read
- Data Processing
- Status Register Update
- Interrupt Generation
- Multiple Transactions

All test cases passed successfully.

---

## Tools Used

- Verilog HDL
- Xilinx Vivado
- Vivado Simulator
- GitHub

---

## Future Improvements

- Support full AXI4 protocol
- Add configurable register bank
- Implement multiple interrupt sources
- Develop SystemVerilog/UVM-based verification

---

## Author

D SHARAN TEJA

Electronics and Communication Engineering Student

Internship Project – BusBridge AXI4-Lite Peripheral IP
