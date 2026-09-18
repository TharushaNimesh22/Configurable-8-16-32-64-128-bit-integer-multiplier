# Configurable Integer Multiplier — 8/16/32/64/128 bit
## Overview

This project implements a configurable unsigned integer multiplier supporting operand widths of 8, 16, 32, 64, and 128 bits.

The main objective of this project is to explore different hardware architectures for integer multiplication and evaluate their impact on latency, resource utilization, and overall performance. Rather than relying solely on the multiplication operator (*) and allowing the synthesis tool to automatically determine the implementation, the design explicitly implements different multiplier architectures to influence the synthesized hardware structure.

The project focuses on understanding how architectural choices affect the resulting hardware, particularly when latency and critical path delay are important design constraints.

## Project Objectives
* Design a configurable multiplier supporting 8/16/32/64/128-bit operands.
* Explore different architectures for hardware multiplication.
* Implement the architectures at RTL level rather than relying entirely on the synthesis tool's inferred multiplier.
* Compare the architectures based on:
  * Latency
  * Critical-path delay
  * Maximum operating frequency
  * Area/resource utilization
* Investigate how the selected architecture affects synthesis and implementation results.

