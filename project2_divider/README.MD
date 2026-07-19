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

The divider verification environment consists of multiple verification stages.

### Reference-Model Verification

File:

`tb_divider_refmodel.vhd`

The testbench:

* Applies divider transactions
* Calculates expected quotient values independently
* Waits for operation completion
* Compares DUT output against the reference model
* Reports mismatches automatically

---

### Scoreboard-Based Verification

File:

`tb_divider_mini_scoreboard.vhd`

The testbench introduces:

* Reusable checker procedures
* Pass/fail counters
* Automated verification summaries
* Separation between stimulus and checking logic

---

### Corner-Case Verification

File:

`tb_divider_corner_cases.vhd`

The testbench verifies:

* Boundary operand values
* Small and large division cases
* Quotient behavior across representative scenarios

---

### Robustness Verification

File:

`tb_divider_robustness.vhd`

The testbench verifies:

* Maximum input conditions
* Reset assertion during active division
* Recovery after reset


### Divide-by-Zero Verification

File:

`tb_divider_divbyzero.vhd`

The testbench verifies:

* Divide-by-zero detection
* Defined error response behavior
* Recovery from error transactions

---

## Verification Objectives

The verification environment verifies:

* Reset behavior
* Divider start and ready handshake
* Quotient correctness
* Multiple sequential transactions
* Reference-model based checking
* Scoreboard-based result tracking
* Boundary and corner-case scenarios
* Reset recovery during active operation
* Divide-by-zero handling
* Error response verification

---

## Learning Outcome

This project demonstrates the evolution from basic directed verification toward a structured verification environment.

The verification flow introduces:

* Reference models for independent expected-value generation
* Reusable checker procedures
* Scoreboard concepts
* Data-driven verification
* Corner-case testing
* Robustness testing
* Error-condition verification

The testbench architecture separates:

* Transaction generation
* Expected behavior definition
* DUT observation
* Result checking

This structure provides a foundation for future verification concepts such as transaction-level modeling, BFMs, protocol verification, and regression environments.

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
