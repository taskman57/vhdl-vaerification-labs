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

### Reference-Model Testbench

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

## Verification Objectives

The verification environment checks:

* Reset behavior
* Start/ready handshake operation
* Quotient correctness
* Multiple sequential transactions
* Corner-case input combinations
* Automated verification reporting

---

## Learning Outcome

This project demonstrates the progression from basic checking toward structured verification methodology.

The reference model provides independent expected behavior, while the scoreboard collects and summarizes verification results.

The data-driven approach separates verification scenarios from execution logic, providing a foundation for scalable testbench development.

---

## Status

✔ Commit 1 Completed

Reference-model based verification implemented and validated.

✔ Commit 2 Completed

Mini scoreboard implemented with pass/fail tracking and verification summary reporting.

✔ Commit 3 Completed

Data-driven corner-case verification implemented with expanded divider test coverage.
