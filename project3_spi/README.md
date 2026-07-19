# Project 3 - SPI Byte Engine Verification

## Goal

Verify a reusable SPI byte transfer engine using functional bring-up techniques.

The project establishes a baseline for verifying the SPI protocol.

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

---

## Verification Objectives

The verification environment verifies:

* Reset behavior
* SPI byte transmission
* SPI byte reception
* Correct serial bit ordering

---

## Learning Outcome

This project demonstrates the initial functional simulation of the SPI protocol.

The verification architecture is intended to separate:

* Transaction generation
* DUT observation

This structure will serve as the foundation for future advanced verification stages.

---

## Status

✔ Commit 1 Completed

Functional bring-up completed.

Next milestone: Directed self-checking verification, reusable capture/checker procedures, and automatic PASS/FAIL reporting.