# VHDL Verification Lab

Practical VHDL verification lab using GHDL and GTKWave to learn verification methodology through real FPGA modules-
such as counters, SPI, divider, and AXI-Lite designs.

---

## Objective

The goal of this repository is to learn FPGA verification methodology through hands-on projects rather than relying-
on commercial simulators or advanced verification frameworks.

Topics explored include:

- Self-checking testbenches
- Assertions
- Directed testing
- Bus Functional Models (BFMs)
- Reference models
- Regression testing
- Protocol verification
- Reusable verification components

---

## Toolchain

Current environment:

- GHDL 6.0.0
- GTKWave
- VHDL-2008 (limited by GHDL support)

---

## Verification Methodology & Concepts

This repository follows a structured verification roadmap designed to teach methodology through progressive hands-on projects. To ensure a deep understanding of the underlying principles—such as the VHDL simulation engine and delta-cycle behavior—the following conceptual documentation is available:

*   [Simulation Engine Fundamentals](docs/transaction_level_modeling.md)

*Additional methodology guides (e.g., Scoreboards, BFM, Functional Coverage) will be added to this section as the repository projects evolve.*

---

### Project 1 - Counter Verification

Completed a full verification flow using a simple counter design.

#### Achievements

- Directed verification testbench implemented
- Procedure-based automated self-checking testbench implemented
- Session-based error tracking signal added (`error_detected`)
- Repeated verification sessions supported
- Introduction of reusable checker concept

#### Learning Outcome

This project demonstrates the evolution from basic directed verification to scalable self-checking testbench design.

---

#### Status

✔ Completed

### Project 2 - Sequential Truncated Restoring Divider

The verification environment uses a reference model, scoreboard, and data-driven stimulus approach to verify a sequential divider implementation.

#### Achievements

* Implemented reference-model based verification
* Added automatic expected-result generation
* Implemented mini scoreboard infrastructure
* Added pass/fail tracking and simulation summaries
* Introduced data-driven test vector execution
* Added corner-case verification scenarios

#### Verification Concepts Introduced

* Reference models
* Scoreboards
* Self-checking testbenches
* Data-driven verification
* Corner-case testing

#### Learning Outcome

This project demonstrates the evolution from individual directed checks toward a structured verification environment.

The testbench architecture separates:

* DUT interaction
* Expected-result generation
* Result checking
* Verification scenarios

This separation allows verification complexity to grow without requiring a complete testbench rewrite.

#### Status

✔ Completed
