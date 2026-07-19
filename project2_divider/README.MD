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
* Calculates the expected quotient mathematically
* Waits for operation completion
* Compares DUT outputs against the reference model
* Reports mismatches automatically

### Scoreboard-Based Testbench

File:

`tb_divider_mini_scoreboard.vhd`

The testbench extends the reference-model approach by:

* Recording pass/fail results
* Reporting individual test outcomes
* Continuing execution after failures
* Producing a final verification summary

This introduces the basic scoreboard concept used in modern verification environments.

---

## Verification Objectives

The following behaviors are verified:

* Reset behavior
* Start/ready handshake operation
* Quotient correctness
* Multiple sequential transactions
* Representative corner-case scenarios
* Verification result collection and reporting

---

## Learning Outcome

This project demonstrates the progression from direct result checking to structured verification methodology.

The reference model provides an independent source of expected behavior, while the scoreboard collects and summarizes verification results across the entire test run.

Together, these concepts form the basis for scalable verification environments used in FPGA and ASIC development.

---

## Status

✔ Commit 1 Completed

Reference-model based verification implemented and validated.

✔ Commit 2 Completed

Mini scoreboard implemented with pass/fail tracking, result reporting, and corner-case verification scenarios.

---

## Additional Verification Features

The scoreboard-based testbench:

* Tracks pass and fail counts
* Reports per-test PASS/FAIL messages
* Continues execution after failures
* Produces a final verification summary

File:

`tb_divider_mini_scoreboard.vhd`

This introduces the fundamental scoreboard concept that will later be expanded for protocol-oriented verification environments.
