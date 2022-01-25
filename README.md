# AM386-SX DEVELOPMENT BOARD
- Introduction
- Problem statement
- Design goals
- Design Constraints
- Benefits

## INTRODUCTION
<p> Implimenting any FPGA independant soft-core processor is difficult.  The complexity, maturity, coding style, software compatability varies from core to core.  x86 isn't going anywhere any time soon for example,  8051 processors are still widly used in embedded designs.  The 80386 32-bit microprocessor is considered by many as the 1st "real" 32-bit microprocessor.  It's paging and protected mode structure continues to this day.</p>

<p> The purpose of this project is to develop a "baseline" model so a soft-core x86 processor can be implimented with full software compatability.  This has been done,  </p>

## PROBLEM STATEMENT
- overly complex cores take longer to discect and impliment.
- lack of documentation or examples.
- lack of software support.  For example, if you roll your own core, you'll also have to either write all your own software, or write a compiler.  Neither are good options.

## DESIGN GOALS
- x86 microprocessor (hardware)
- 3.3v operation (for use with FPGA and modern memories).
- low pin count
- cheap development board integration.
- 

## DESIGN CONSTRAINTS

## BENEFITS
