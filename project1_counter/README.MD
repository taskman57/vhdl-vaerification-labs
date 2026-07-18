# Project 1 - Counter Verification

## Goal

Project 1 demonstrates a step-by-step evolution of verification methodology using a simple synchronous counter.

The focus is on moving from directed verification to automated self-checking testbenches.

---

## DUT Overview

The Device Under Test (DUT) is a simple 4-bit synchronous counter.

### Behavior:
- Increments on rising clock edge
- Has synchronous reset
- Saturates at a maximum value (no wrap-around)
- Fully deterministic behavior

---

## Verification Approach

This project is implemented in two stages:

### 1. Directed Verification (Basic Testbench)

File:
- tb_counter_basic.vhd

Features:
- Step-by-step stimulus
- Explicit assertions at each clock cycle
- Manual expected-value checking
- Waveform-based debugging (GTKWave)

Purpose:
- Understand testbench structure
- Learn assertion-based verification
- Learn debugging flow

### 2. Automated Self-Checking Verification

File:
- tb_counter_auto.vhd

Features:
- Procedure-based checker (`check_count`)
- Reference-model comparison
- Error tracking signal (`error_detected`)
- Session-based verification (reset clears errors)
- Repeated verification sessions
- Assertion-based validation

Purpose:
- Introduce reusable verification concepts
- Prepare for complex DUTs (SPI, AXI, Divider)
- Demonstrate self-checking testbench design

---

## Key Learning Outcomes

- Directed vs automated verification
- Assertion-based checking
- Reference model concept
- Testbench scalability
- Structured verification methodology evolution

---

## Toolchain

- GHDL 6.0.0
- GTKWave
- VHDL-2008 (limited support)

---

## Status

Project 1 is complete and demonstrates a full verification progression from basic directed testing to automated self-checking methodology.