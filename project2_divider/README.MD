# Project 2 - Sequential Truncated Restoring Divider

## Goal

Verify a sequential divider using a reference-model based verification methodology and introduce the fundamentals of scoreboard-driven verification.

The objective is to independently calculate expected results, compare them against DUT outputs, and collect verification statistics across multiple test scenarios.

---

## DUT Overview

The DUT is a sequential truncated restoring divider.

Features:

* Multi-cycle division operation
* Start signal (`ena_i`)
* Ready indication (`q_rdy_o`)
* Quotient output (`quot_o`)

The divider returns only the quotient and intentionally discards the remainder.

---

## Verification Approach

### Reference-Model Verification

File:

`tb_divider_refmodel.vhd`

The testbench:

* Applies divider transactions
* Calculates expected quotient values independently
* Waits for operation completion
* Compares DUT output against the reference model

---

### Scoreboard-Based Verification

File:

`tb_divider_mini_scoreboard.vhd`

The testbench introduces a reusable mini scoreboard.

Features:

* PASS/FAIL tracking
* Per-test result reporting
* Verification summary generation
* Continued execution after failures

---

### Data-Driven Corner-Case Verification

File:

`tb_divider_corner_cases.vhd`

The testbench extends the scoreboard approach using a test-vector based stimulus model.

Features:

* Separation of test data and execution flow
* Reusable test execution loop
* Boundary-condition verification scenarios
* Automated result collection

---

### Robustness Verification

File:

`tb_divider_robustness.vhd`

The testbench extends verification beyond arithmetic corner cases and focuses on DUT robustness.

Features:

* Quotient-width boundary verification
* Maximum divisor verification
* Dividend-less-than-divisor boundary verification
* Reset recovery testing during an active division operation

Boundary scenarios include:

* Smallest non-zero quotient
* Maximum supported quotient value
* Maximum supported divisor value
* Dividend smaller than divisor

The reset recovery test verifies that an active division operation is correctly aborted and that the DUT can successfully process a new transaction after reset.

---

## Verification Objectives

The verification environment checks:

* Reset behavior
* Start/ready handshake operation
* Quotient correctness
* Multiple sequential transactions
* Arithmetic corner-case scenarios
* Quotient-width boundary conditions
* Divisor boundary conditions
* Reset recovery during an active division operation
* Automated result reporting through a reusable scoreboard

---

## Learning Outcome

This project demonstrates the progression from simple directed verification toward a structured verification environment.

The verification flow introduces:

* Reference-model based checking
* Reusable scoreboard concepts
* Data-driven test execution
* Corner-case verification
* Robustness verification

The testbench architecture separates:

* DUT interaction
* Expected-result generation
* Result checking
* Verification scenarios

This separation improves scalability and maintainability while providing a foundation for future verification concepts such as transaction abstraction, BFMs, and protocol verification.

---

## Status

✔ Commit 1 Completed

Reference-model verification implemented and validated.

✔ Commit 2 Completed

Mini scoreboard implemented with pass/fail tracking and verification summary reporting.

✔ Commit 3 Completed

Data-driven corner-case verification implemented with expanded arithmetic test coverage.

✔ Commit 4 Completed

Robustness verification implemented, including boundary-condition testing and reset recovery verification.
