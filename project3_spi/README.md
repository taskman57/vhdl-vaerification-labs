# Project 3 - SPI Byte Engine Verification

## Goal

Verify a reusable SPI byte transfer engine using progressively more advanced verification techniques.

The project establishes a professional, reusable foundation for verifying SPI-based controllers.

---

## DUT Overview

The DUT is a single-byte SPI transfer engine supporting simultaneous transmit/receive, LSB-first transmission, and external flow control via `start_i`.

---

## Verification Approach

### Functional Bring-up
* `tb_spi_byte_bringup.vhd`: Basic waveform-based validation.

### Directed Self-Checking Verification
* `tb_spi_byte_verify.vhd`: Reusable capture/checker procedures with automatic pass/fail reporting.

### Corner-Case Verification
* `tb_spi_byte_corner.vhd`: Stress tests for edge-case data patterns.

### Scoreboard Verification
* `tb_spi_byte_scoreboard.vhd`: Decoupled transaction recording and checking.

### Randomized Verification
* `tb_spi_byte_random.vhd`: Constraint-based random testing for statistical coverage.

### Robustness Verification
* `tb_spi_byte_robust.vhd`: Validates system stability under stress conditions
    * **Reset Abort**: Verifies engine recovery after reset during an active transfer
    * **Busy/Flow Control**: Validates behavior when `start_i` is asserted during `busy_o`
    * **Back-to-Back Transfers**: Ensures continuity between rapid transactions
    * **Pulse-Width Variation**: Tests sensitivity of control signals and consistency of `done_o`

---

## Learning Outcome

This project completes the transition from simple functional testing to a comprehensive verification environment:

*   **Foundation**: Directed and self-checking testbenches.
*   **Architecture**: Transaction-based scoreboarding.
*   **Quality**: Constraint-random verification.
*   **Hardening**: Robustness and protocol stress testing.

---

## Status

✔ **Project 3 Completed**

All verification phases passed. System is ready for Project 4: SPI slave Bus Functional Model (BFM).