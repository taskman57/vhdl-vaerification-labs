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

The divider verification environment evolved from reference-model checking into a structured scoreboard-based verification flow.

The environment verifies arithmetic correctness, boundary conditions, reset recovery, and error handling scenarios.

#### Achievements

- Reference-model based verification implemented
- Reusable scoreboard infrastructure created
- Automated pass/fail reporting added
- Corner-case verification introduced
- Robustness testing performed
- Divide-by-zero handling verified
- Multiple checker paths implemented for normal and error transactions
- Randomized reference-model verification added with output-width aware checking

#### Verification Concepts Introduced

* Reference models
* Scoreboards
* Self-checking testbenches
* Data-driven verification
* Corner-case testing
* Robustness verification
* Reset recovery verification

#### Learning Outcome

This project demonstrates the evolution from individual directed checks toward a structured verification environment.

The testbench architecture separates:

* DUT interaction
* Expected-result generation
* Result checking
* Verification scenarios

This separation allows verification complexity to increase without requiring major changes to the verification infrastructure.

#### Status

✔ Completed

Randomized verification stage added.

### Project 3 - SPI Byte Engine Verification

The SPI verification project introduces protocol-oriented verification using a reusable SPI byte transfer engine.

The verification environment begins with functional bring-up.

#### Achievements

- SPI byte transfer engine functionally verified
- Directed transmit-path verification completed
- Directed receive-path verification completed

#### Verification Concepts Introduced

* Directed verification
* Waveform-based functional validation

#### Learning Outcome

This project begins the transition from functional simulation toward structured protocol verification.

#### Status

◐ In Progress

Functional bring-up completed.

Next milestone: Directed self-checking verification and reusable verification procedures.