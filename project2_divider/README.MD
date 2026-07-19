# Project 2 - Sequential Truncated Restoring Divider

## Goal

Verify a sequential divider using a reference-model based verification approach.

This project introduces the concept of computing expected DUT behavior independently and automatically comparing it against the actual DUT output.

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
* Computes the expected quotient mathematically
* Waits for divider completion
* Compares DUT output against the reference model
* Reports mismatches automatically

---

## Verification Objectives

The following behaviors are verified:

* Reset behavior
* Start operation
* Ready signal generation
* Quotient correctness
* Multiple sequential transactions

---

## Learning Outcome

This project introduces reference-model based verification.

Unlike directed testing, expected results are calculated automatically rather than being hard-coded into assertions.

This represents the first step toward scalable verification environments and future scoreboard-based verification.

---

## Status

✔ Commit 1 Completed

Reference-model verification implemented and validated.
