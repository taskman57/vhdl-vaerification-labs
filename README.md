# VHDL Verification Labs

A structured collection of hands-on VHDL verification projects designed to teach verification methodology through progressively more advanced examples.

The repository starts with simple directed verification and evolves toward reusable verification infrastructure, scoreboards, BFMs, transaction-level verification, protocol verification, regression testing, and constrained-random methodologies.

Each project contains:

- A Design Under Test (DUT)
- Multiple verification environments
- Self-checking testbenches
- Documentation of verification concepts
- Progressive methodology improvements

The goal is to demonstrate how industrial verification environments evolve while remaining entirely within the VHDL ecosystem.

---

## Toolchain

Current environment:

- GHDL 6.0.0
- GTKWave
- VHDL-2008 (limited by GHDL support)

---

### Project 0 - environment Bootstrap

Establish a lightweight environment compatible with GHDL.

See:

project0_environment_bootstrap/README.md

### Project 1 - Counter Verification

Project 1 introduces basic verification of a simple synchronous counter.

#### Current Status (Commit 1)

- Counter DUT implemented
- One directed testbench implemented (`tb_counter_basic.vhd`)
- Verification based on assertions and step-by-step checking
- Waveform inspection using GTKWave