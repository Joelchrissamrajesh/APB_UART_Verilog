# APB-UART Controller RTL Design and Verification

## Project Overview
This project implements an APB-based UART controller in Verilog. The design includes an APB register interface, UART transmitter, UART receiver, TX FIFO, RX FIFO, baud-rate divisor logic, interrupt/status registers, and a directed Verilog testbench.

The APB master configures UART registers through APB read/write transactions. Data written to address `0x00` is pushed into the TX FIFO and transmitted serially through `txd`. The receiver samples serial data from `rxd`, converts it back into parallel data, stores it in RX FIFO, and allows the APB master to read the received data from address `0x00`.

## Features
- APB register interface
- UART transmitter and receiver
- TX FIFO and RX FIFO
- Configurable Line Control Register `LCR`
- Baud-rate divisor registers
- Interrupt Enable Register `IER`
- Interrupt Identification Register `IIR`
- Line Status Register `LSR`
- Parity support
- Framing error detection
- Break error detection
- RX overrun detection
- Timeout detection
- Directed Host-A to Host-B UART testbench

## Architecture

```text``
APB Master
    |
    | APB Read/Write
    |
Register Block
    |
    |------------------> TX FIFO ---> UART Transmitter ---> TXD
    |
    |<------------------ RX FIFO <--- UART Receiver <------ RXD 

## Main Modules

1. uart_top
Top-level module that connects the register block, transmitter, and receiver.

2. register_block
Handles APB read/write transactions, register access, baud-rate divisor logic, interrupt generation, TX FIFO write enable, and RX FIFO read enable.

3. transmitter
Implements UART transmit operation using TX FIFO and FSM states such as IDLE, START, BIT0-BIT7, PARITY, STOP1, and STOP2.

4. receiver_block
Receives serial data from rxd, synchronizes it, samples data bits, detects errors, and pushes received data into RX FIFO.

5. fifo_counter
16-depth FIFO used for both TX and RX buffering.

## Register Address Map

| Address | Register    | Description                              |
| ------- | ----------- | ---------------------------------------- |
| `0x00`  | THR/RBR     | Write transmit data / Read received data |
| `0x04`  | IER         | Interrupt Enable Register                |
| `0x08`  | FCR/IIR     | FIFO Control / Interrupt Identification  |
| `0x0C`  | LCR         | Line Control Register                    |
| `0x14`  | LSR         | Line Status Register                     |
| `0x1C`  | Divisor LSB | Baud-rate divisor lower byte             |
| `0x20`  | Divisor MSB | Baud-rate divisor upper byte             |


## Testbench

The testbench instantiates two UART controllers:

HOSTA.txd  --->  HOSTB.rxd

HOSTA is configured through APB writes and transmits data. HOSTB receives the serial data and stores it into its RX FIFO. The received data is read through APB read access.

Test data used:8'h57

Expected result: HOSTB receives 8'h57

## Verification Scenarios

APB register write and read
LCR register configuration
Baud divisor configuration
TX FIFO write operation
UART serial transmission
RX serial reception
RX FIFO data storage
Host-A to Host-B data transfer
Received data readback through APB
Tools Used
Verilog HDL
QuestaSim / ModelSim
Vivado Simulator
Waveform Debug

## Resume Bullet

Designed an APB-based UART controller with configurable LCR, baud-rate divisor, TX/RX FIFOs, interrupt/status registers, transmitter, and receiver. Verified Host-A to Host-B serial data transfer using a directed APB testbench with TXD-to-RXD connection, FIFO access, and data readback.
