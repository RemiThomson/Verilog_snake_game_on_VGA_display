# Verilog Snake Game on VGA Display

Classic **Snake**, recreated entirely in synthesizable Verilog and shown on a 640 × 480 @ 60 Hz VGA monitor.  
The design targets the Digilent **Basys 3** board (Artix-7 XC7A35T-1CPG236C) but can be ported to any FPGA with a spare RGB-video connector.

---

## Table of Contents
1. [Features](#features)  
2. [Repository Layout](#repository-layout)  
3. [Hardware Requirements](#hardware-requirements)  
4. [Quick-Start (Vivado)](#quick-start-vivado)  
5. [Gameplay & Controls](#gameplay--controls)  
6. [Design Overview](#design-overview)  
7. [Customising the Game](#customising-the-game)  
8. [Simulation Tips](#simulation-tips)  
9. [Road-map & Ideas](#road-map--ideas)  
10. [License](#license)

---

## Features
* **True 60 Hz VGA timing** (pixel-perfect 640 × 480).
* **Modular RTL** – each logical block lives in its own file.
* **LFSR-based food generator** → pseudo-random & in-bounds.
* **Two-digit score** on the on-board 7-segment display.
* **Idle / Play / Win / Fail** finite-state machine with timeout.
* **Colour-cycling border** for a retro arcade vibe.
* Fits comfortably inside a Basys 3  
  * < 3 % LUTs – < 2 % BRAM – 0 DSP slices.

---

## General Overview

![System Architecture](Snake_System_Architecture.png)



## Repository Layout

```text
Verilog_snake_game_on_VGA_display/
├── Snake_Game.srcs/
│   ├── sources_1/new/        # All synthesizable RTL
│   │   ├── Wrapper.v         # <- top-level entity
│   │   ├── VGA_Interface.v   # VGA timing generator
│   │   ├── SnakeControl.v    # Body, collisions & rendering
│   │   ├── Navigation_SM.v   # Direction state-machine
│   │   ├── Master_SM.v       # Idle/Play/Win/Fail FSM
│   │   ├── TargetGenerator.v # Pseudo-random food
│   │   ├── ScoreCounter.v    # 2-digit BCD / 7-seg driver
│   │   ├── GenericCounter.v  # Parameterised counters
│   │   └── InvertCorners.v   # Border colour-cycler
│   └── constrs_1/new/
│       └── Snake_Constraints.xdc   # Basys 3 pin-out
├── Snake_System_Architecture.png   # Block diagram
└── README.md                       # You are here
