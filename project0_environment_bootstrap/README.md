# Project 0 - Environment Bootstrap

## Goal

This lab serves as the initial bring-up of the verification toolchain, validating a lightweight and reproducible-
simulation workflow using open-source tools.

The focus is on creating a practical workflow that supports learning verification methodology concepts and applying them-
to real FPGA modules throughout the subsequent projects in this repository.

---

## Toolchain

Verified environment:

* GHDL 6.0.0
* GTKWave
* VHDL-2008

---

## Motivation

Before verifying any DUT, it is important to establish a reliable simulation and debugging workflow.

This project serves as the foundation for all future verification exercises in the repository by validating:

* VHDL compilation
* Elaboration
* Simulation
* Waveform generation
* Waveform analysis

Using a lightweight open-source toolchain allows all projects in this repository to remain fully reproducible without-
requiring commercial simulators.

---

## Verification Philosophy

The objective of this repository is to learn verification methodology rather than simulator-specific features.

As the projects evolve, the verification environments will progressively introduce concepts such as:

* Directed testing
* Self-checking testbenches
* Reusable verification procedures
* Reference models
* Scoreboards
* Randomized testing
* Robustness testing
* Protocol verification
* Transaction-level verification
* Functional coverage
* Regression testing

Project 0 establishes the infrastructure required to support that progression.

---

## Bootstrap Testbench

A minimal testbench is included to validate the simulation environment.

File:

```text
tb_hello.vhd
```

Expected simulation output:

```text
Hello Verification Lab!
```

This testbench serves as the baseline validation of the verification environment before moving to DUT-specific projects.

---

## Deliverables

Project 0 is considered complete when:

* GHDL compiles the testbench successfully.
* Elaboration completes successfully.
* Simulation executes successfully.
* Waveform files are generated correctly.
* GTKWave can display generated waveforms.
* The environment is ready for Project 1 (Counter Verification).

---

## Outcome

At the completion of Project 0, the repository has a reproducible verification workflow that can be used consistently-
throughout all subsequent projects.
