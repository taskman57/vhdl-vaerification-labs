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

File:

`tb_spi_byte_bringup.vhd`

The testbench verifies:

* Basic transmit operation
* Basic receive operation
* Waveform-based functional validation

### Directed Self-Checking Verification

File:

`tb_spi_byte_verify.vhd`

The testbench introduces:

* Directed SPI transmit and receive transactions
* Automatic SPI byte capture
* Reusable capture procedures
* Reusable checker procedures (MOSI/MISO)
* Automatic PASS/FAIL reporting

### Corner-Case Verification

File:

`tb_spi_byte_corner.vhd`

The testbench validates robustness against edge-case data patterns (e.g., alternating patterns, boundary values, nibble boundaries).

### Scoreboard Verification

File:

`tb_spi_byte_scoreboard.vhd`

The testbench introduces:

* Transaction recording (expected vs. actual)
* Non-real-time verification
* Separation of stimulus and checking phases
* Consolidated PASS/FAIL summary reporting

---

## Verification Objectives

The verification environment verifies:

* Reset behavior
* SPI byte transmission
* SPI byte reception
* Correct serial bit ordering
* Corner-case behavior
* Transaction-based scoreboarding

---

## Learning Outcome

This project demonstrates the progression from functional simulation toward protocol-oriented verification.

The verification flow introduces:

* Directed verification
* Self-checking testbenches
* Capture procedures
* Checker procedures
* Scoreboards

The verification architecture separates:

* Transaction generation
* DUT observation
* Result checking

This structure serves as the reusable verification foundation for future SPI-based projects.

---

## Status

✔ Commit 4 Completed

Scoreboard verification completed.

Next milestone: reusable SPI slave Bus Functional Model (BFM).