# Project 3 - SPI Byte Engine Verification

## Goal

Verify a reusable SPI byte transfer engine using progressively more advanced verification techniques.

The project introduces protocol-oriented verification concepts and establishes a reusable foundation for verifying higher-level SPI controllers.

---

## DUT Overview

The DUT is a single-byte SPI transfer engine.

Features:

* Single-byte SPI transmit and receive
* Simultaneous transmit and receive operation
* LSB-first transmission
* External transaction control through `start_i`
* Busy and completion indication

The DUT intentionally focuses on byte-level transfers. Chip-select control and higher-level register transactions are implemented by upper protocol layers.

---

## Verification Approach

### Functional Bring-up

File: `tb_spi_byte_bringup.vhd`
The testbench verifies basic transmit/receive and provides waveform-based validation.

### Directed Self-Checking Verification

File: `tb_spi_byte_verify.vhd`
Introduces reusable capture/checker procedures and automatic PASS/FAIL reporting.

### Corner-Case Verification

File: `tb_spi_byte_corner.vhd`
Validates robustness against edge-case data patterns (e.g., alternating patterns, boundaries).

### Scoreboard Verification

File: `tb_spi_byte_scoreboard.vhd`
Introduces transaction-based scoreboarding and decoupled stimulus/checking.

### Randomized Verification

File: `tb_spi_byte_random.vhd`

The testbench introduces:

* Random stimulus generation using `IEEE.math_real`
* Configurable test iterations via `NUM_TESTS_G`
* Statistical coverage increase
* Automated verification of random transaction sequences

---

## Verification Objectives

The verification environment verifies:

* Reset behavior
* SPI byte transmission/reception
* Correct serial bit ordering
* Corner-case and transaction-based scoreboarding
* **Randomized stimulus and protocol robustness**

---

## Learning Outcome

This project demonstrates the progression from functional simulation toward comprehensive, industry-standard verification.

The verification flow includes:

* Directed verification
* Self-checking testbenches
* Capture and checker procedures
* Scoreboards
* **Randomized constraint-based verification**

The architecture remains decoupled, separating generation, observation, and checking.

---

## Status

✔ Commit 5 Completed

Randomized verification completed.

Next milestone: reusable SPI slave Bus Functional Model (BFM).