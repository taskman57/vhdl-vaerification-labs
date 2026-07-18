# Project 1 - Counter Verification

## Goal

Project 1 introduces basic VHDL verification using a simple synchronous counter.

The focus is on learning how to verify digital logic using **directed testbenches and assertions** with GHDL.

This is the first step beyond the bootstrap environment (Project 0).

---

## DUT Overview

The Device Under Test (DUT) is a simple 4-bit synchronous counter.

### Behavior:
- Counter increments on rising clock edge
- Active-high synchronous reset
- Counts up to a limited value (saturating behavior)
- Output is deterministic and easy to verify

---

## Verification Approach

This project uses a **single directed testbench**:

### 1. Basic Directed Testbench

File:

tb_counter_basic.vhd

Features:

- Clock generation process
- Reset stimulus generation
- Step-by-step verification using assertions
- Direct comparison against expected values
- Simple pass/fail reporting

---

## Key Verification Concepts Introduced

- Testbench structure in VHDL
- DUT instantiation
- Clock and reset generation
- Directed stimulus methodology
- Assertion-based checking
- Basic self-checking behavior
- Waveform-based debugging using GTKWave

---

## Toolchain

- GHDL 6.0.0
- GTKWave
- VHDL-2008 (limited support depending on toolchain)

---

## Expected Result

A successful simulation should:

- Run without assertion failures
- Produce step-by-step verification checks
- Print a final confirmation message:

Counter basic verification passed

---

## Notes

This project intentionally avoids reusable verification components or automated frameworks.

Those concepts are introduced in the next stage (Project 1 - Commit 2).