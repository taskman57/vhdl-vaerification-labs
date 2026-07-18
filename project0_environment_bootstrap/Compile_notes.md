# Project 0 - Compilation Notes

## Environment

The following setup was used for Project 0.

### GHDL

GHDL is installed and available through the system environment variables (`PATH`).

Example:

```text
ghdl --version
```

can be executed from any command prompt.

### GTKWave

GTKWave is installed and its `bin` directory is available through the system environment variables (`PATH`).

Example:

```text
gtkwave --version
```

can be executed from any command prompt.

---

## Bootstrap Testbench

Source file:

```text
tb_hello.vhd
```

---

## Compilation

Run:

```cmd
ghdl -a --std=08 tb_hello.vhd
```

---

## Elaboration

```cmd
ghdl -e --std=08 tb_hello
```

---

## Simulation

```cmd
ghdl -r --std=08 tb_hello --wave=hello.ghw --stop-time=200ns
```

Expected console output:

```text
Hello Verification Lab!
```

Generated waveform:

```text
hello.ghw
```

---

## Waveform Viewing

Open GTKWave:

```cmd
gtkwave hello.ghw
```

---

## Notes

This project serves as the initial bring-up of the verification toolchain. The objective is to establish a lightweight and reproducible baseline environment using GHDL and GTKWave.

The goal is to validate the complete simulation workflow—from compilation and elaboration to waveform generation and analysis—creating a reliable foundation for all subsequent verification projects in this repository.

No DUT-specific verification concepts are introduced here. The focus is strictly on environment setup, simulation execution, and tool integration.

Project 0 operates as the validated entry point to the verification methodology roadmap, which officially begins with Project 1 (Counter Verification).