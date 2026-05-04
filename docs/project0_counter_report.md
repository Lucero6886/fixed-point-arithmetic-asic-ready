# Project 0: Counter RTL-To-GDSII Baseline

## 1. Project Objective

Project 0 is the first baseline project in the ASIC-ready hardware design roadmap.

The main objective is to verify that a simple Verilog RTL design can go through the complete open-source RTL-to-GDSII flow:

```text
RTL design
→ RTL simulation
→ waveform inspection
→ logic synthesis
→ physical implementation
→ DRC/LVS/Antenna signoff
→ final GDSII generation
```

This project does not aim to design a complex circuit. Instead, it helps the learner understand the complete digital IC implementation flow using a very small and understandable sequential circuit.

The selected design is a simple digital counter because it contains the essential components of a synchronous digital system:

```text
clock
reset
state register
next-state logic
output signal
```

At the end of this project, the learner should understand how a basic Verilog design moves from RTL to a physical layout.

---

## 2. Why This Project Is Important

Before implementing a Polar encoder, SC decoder, neural decoder, or any complex hardware accelerator, it is necessary to understand the basic ASIC implementation flow.

A complex design may fail for many reasons:

```text
RTL bug
testbench bug
synthesis issue
timing violation
routing congestion
DRC violation
LVS mismatch
antenna violation
OpenLane configuration error
```

If the basic flow is not understood using a simple design, debugging a complex decoder later will be very difficult.

Therefore, Project 0 acts as a flow-validation project.

The central question is:

```text
Can we take a simple Verilog counter from RTL all the way to clean GDSII using open-source tools?
```

If the answer is yes, then the toolchain is ready for larger designs.

---

## 3. Technical Background

### 3.1 What Is RTL?

RTL stands for Register Transfer Level.

At RTL, hardware is described using registers and combinational logic. For a counter, the RTL describes how the count value changes at each clock edge.

A simplified behavior is:

```text
if reset is active:
    count = 0
else:
    count = count + 1
```

RTL is not software. It is a description of digital hardware structure and behavior.

---

### 3.2 What Is A Sequential Circuit?

A sequential circuit is a circuit whose output depends not only on current inputs, but also on stored state.

A counter is sequential because it remembers its previous count value.

The key element is the register:

```text
count register
```

At every active clock edge, the register updates to a new value.

---

### 3.3 What Is Simulation?

Simulation checks whether the RTL behaves correctly before synthesis.

For the counter, simulation verifies:

```text
the reset works correctly
the counter increments correctly
the output changes at clock edges
the counter wraps around after reaching its maximum value
the waveform matches the expected behavior
```

Simulation only checks functional behavior. It does not guarantee that the design can be physically implemented.

---

### 3.4 What Is Synthesis?

Synthesis converts RTL into a gate-level representation.

For example, the RTL expression:

```verilog
count <= count + 1;
```

may be synthesized into:

```text
flip-flops
XOR gates
AND gates
carry logic
```

Synthesis answers the question:

```text
What hardware gates are needed to implement this RTL?
```

---

### 3.5 What Is OpenLane?

OpenLane is an open-source ASIC physical design flow.

It takes Verilog RTL and configuration files, then performs:

```text
synthesis
floorplanning
placement
clock tree synthesis
routing
DRC checking
LVS checking
antenna checking
GDSII generation
```

OpenLane is used in this roadmap as the main open-source RTL-to-GDSII implementation flow.

---

### 3.6 What Is GDSII?

GDSII is the final layout file format used in integrated circuit fabrication.

In this project, generating GDSII means that the design has reached the final physical layout stage of the selected OpenLane flow.

However, generating GDSII in an educational open-source flow should not be overstated as commercial tapeout readiness. It means the design passed the selected flow and checks under the selected configuration.

---

## 4. Design Under Test

The design under test is a simple 4-bit counter.

A typical counter interface is:

```verilog
module counter_4bit (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [3:0] count
);
```

The behavior is:

```text
When rst_n = 0:
    count is reset to 0

When rst_n = 1:
    count increments by 1 on each rising clock edge
```

Because the output is 4 bits wide, the counter naturally wraps around:

```text
0 → 1 → 2 → ... → 14 → 15 → 0 → ...
```

This makes the counter simple enough for flow learning but still meaningful as a sequential RTL design.

---

## 5. Expected File Structure

The expected file structure for Project 0 is:

```text
rtl/
  counter_4bit.v

tb/
  tb_counter_4bit.v

sim/
  run_counter_4bit.sh
  waveforms/
    counter_4bit.vcd

synth/
  counter_4bit.ys
  reports/
    counter_4bit_yosys.log
  netlist/
    counter_4bit_synth.v

asic_openlane/
  counter_4bit/
    config/
    reports/
    results/
```

Depending on the actual repository version, file names may be slightly different.

The important point is that the project should contain:

```text
RTL source
testbench
simulation script
synthesis script
OpenLane configuration
summary report
selected final results
```

---

## 6. RTL Design Explanation

The counter contains one main register:

```text
count[3:0]
```

This register stores the current counter value.

At every rising clock edge:

```text
if reset is active:
    count becomes 0
else:
    count becomes count + 1
```

The design is sequential because the output depends on previous state.

This makes it a good first design for ASIC flow learning, because most real digital systems contain registers and clocked behavior.

---

## 7. Example RTL Code

A typical implementation is:

```verilog
`timescale 1ns/1ps

module counter_4bit (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [3:0] count
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 4'b0000;
        end else begin
            count <= count + 4'b0001;
        end
    end

endmodule
```

Important points:

```text
posedge clk means the counter updates on the rising clock edge.
negedge rst_n means reset is active-low and asynchronous.
count <= count + 1 describes increment behavior.
```

---

## 8. Testbench Objective

The testbench should verify that:

```text
1. The counter resets to 0.
2. The counter increments after reset is released.
3. The counter wraps from 15 back to 0.
4. A waveform file is generated for inspection.
```

The testbench should include:

```text
clock generation
reset sequence
simulation runtime
waveform dump
basic output checking or observation
```

---

## 9. Example Testbench Structure

A typical clock generator is:

```verilog
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end
```

This creates a 10 ns clock period.

A typical reset sequence is:

```verilog
rst_n = 1'b0;
#20;
rst_n = 1'b1;
```

A typical waveform dump is:

```verilog
$dumpfile("sim/waveforms/counter_4bit.vcd");
$dumpvars(0, tb_counter_4bit);
```

---

## 10. RTL Simulation Flow

Run simulation using Icarus Verilog:

```bash
iverilog -g2012 -o sim/counter_4bit_sim \
    rtl/counter_4bit.v \
    tb/tb_counter_4bit.v

vvp sim/counter_4bit_sim
```

If a script exists, use:

```bash
./sim/run_counter_4bit.sh
```

Expected simulation result:

```text
Simulation completed.
Waveform generated.
No functional error observed.
```

The waveform file should be generated at:

```text
sim/waveforms/counter_4bit.vcd
```

---

## 11. What To Check In The Waveform

Open the waveform using GTKWave:

```bash
gtkwave sim/waveforms/counter_4bit.vcd
```

Signals to inspect:

```text
clk
rst_n
count[3:0]
```

Expected behavior:

```text
During reset:
    count = 0

After reset is released:
    count increments every clock cycle

After count reaches 15:
    count wraps back to 0
```

This confirms that the RTL counter behaves correctly.

---

## 12. Yosys Synthesis Flow

A typical Yosys script may look like:

```tcl
read_verilog rtl/counter_4bit.v

hierarchy -check -top counter_4bit

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/counter_4bit_synth.v
```

Run synthesis:

```bash
yosys -s synth/counter_4bit.ys | tee synth/reports/counter_4bit_yosys.log
```

---

## 13. What To Check In The Yosys Report

Important fields:

```text
Number of wires
Number of wire bits
Number of public wires
Number of public wire bits
Number of cells
DFF cells
logic gates
```

For a counter, we expect to see:

```text
flip-flops for the count register
combinational logic for incrementing
```

The exact cell count depends on synthesis options and target library.

---

## 14. OpenLane Design Setup

A typical OpenLane design folder is:

```text
~/OpenLane/designs/counter_4bit/
  config.tcl
  src/
    counter_4bit.v
```

The `config.tcl` file defines:

```text
design name
Verilog source files
clock port
clock period
die area or utilization
placement density
standard cell library
```

Example configuration:

```tcl
set ::env(DESIGN_NAME) counter_4bit

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_PERIOD) "10"

set ::env(FP_CORE_UTIL) 50

set ::env(PL_TARGET_DENSITY) 0.45

set ::env(SYNTH_STRATEGY) "AREA 0"
```

The exact configuration may differ depending on the OpenLane version and repository organization.

---

## 15. Running OpenLane

From the OpenLane directory:

```bash
cd ~/OpenLane
make mount
```

Inside the OpenLane container:

```bash
./flow.tcl -design counter_4bit
```

After the run finishes, exit the container:

```bash
exit
```

---

## 16. OpenLane Output Files

A successful OpenLane run creates a run folder:

```text
~/OpenLane/designs/counter_4bit/runs/RUN_...
```

Important output files include:

```text
reports/metrics.csv
reports/manufacturability.rpt
reports/signoff/drc.rpt
logs/signoff/*lvs*.log
logs/signoff/*arc*.log
results/final/gds/counter_4bit.gds
```

---

## 17. Signoff Checks

### 17.1 Magic DRC

DRC stands for Design Rule Check.

It checks whether the layout follows manufacturing design rules.

Expected result:

```text
Total Magic DRC violations = 0
```

---

### 17.2 LVS

LVS stands for Layout Versus Schematic.

It checks whether the physical layout matches the synthesized netlist.

Expected result:

```text
Design is LVS clean
```

---

### 17.3 Antenna Check

Antenna violations are related to manufacturing plasma charging effects.

Expected result:

```text
Pin violations = 0
Net violations = 0
```

---

## 18. Expected Final Success Criteria

Project 0 is considered successful if the following are achieved:

```text
RTL simulation passed
Yosys synthesis completed
OpenLane flow completed
GDSII generated
Magic DRC violations = 0
LVS clean
Antenna violations = 0
```

If timing is checked, we also expect:

```text
WNS >= 0
TNS = 0
```

---

## 19. Result Summary

Fill this section with the actual final run result.

```text
Run directory:
GDSII file:
Flow status:
Total runtime:
Clock period:
Die area:
Synth cell count:
Wire length:
Vias:
WNS:
TNS:
Critical path:
Magic DRC violations:
LVS:
Pin antenna violations:
Net antenna violations:
```

Example status format:

```text
Flow completed
GDSII generated
Magic DRC violations = 0
LVS clean
Pin antenna violations = 0
Net antenna violations = 0
```

---

## 20. Interpretation Of The Result

If the final result is clean, Project 0 confirms that:

```text
1. The Verilog RTL is syntactically valid.
2. The design can be simulated.
3. The design can be synthesized.
4. The design can be placed and routed.
5. The design can generate GDSII.
6. The OpenLane environment is working.
```

This project does not prove that the designer understands all advanced physical design issues. However, it establishes the toolchain foundation required for later projects.

---

## 21. Common Problems And Debugging

### Problem 1: OpenLane Cannot Find Verilog File

Possible causes:

```text
wrong file path in config.tcl
Verilog file not copied to src/
incorrect VERILOG_FILES setting
```

Fix:

```bash
ls ~/OpenLane/designs/counter_4bit/src
```

Check `config.tcl`:

```tcl
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]
```

---

### Problem 2: Clock Port Not Found

Possible cause:

```text
CLOCK_PORT name does not match RTL port name
```

Fix:

```text
If RTL uses clk, config must use:
set ::env(CLOCK_PORT) "clk"
```

---

### Problem 3: Top Module Name Mismatch

Possible cause:

```text
DESIGN_NAME in config.tcl does not match the top module name
```

Fix:

```text
Check the RTL module name.
Check DESIGN_NAME in config.tcl.
Check hierarchy errors in synthesis logs.
```

---

### Problem 4: LVS Fails

Possible causes:

```text
wrong top module
wrapper mismatch
synthesis mismatch
layout-netlist mismatch
```

Fix:

```text
Check module name in RTL.
Check DESIGN_NAME in config.tcl.
Check synthesis log.
Check LVS log.
```

---

### Problem 5: Antenna Violations

Possible fix:

```tcl
set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1
```

For this small counter, antenna violations are usually not difficult to fix.

---

### Problem 6: Timing Violation

Possible causes:

```text
clock period too aggressive
routing delay too large
placement density too high
```

Possible fixes:

```text
relax CLOCK_PERIOD
increase die area
reduce placement density
use a timing-oriented synthesis strategy
```

---

## 22. Lessons Learned

Project 0 teaches the following key lessons:

```text
1. RTL simulation and physical signoff are different stages.
2. A design can pass simulation but still fail physical implementation.
3. OpenLane produces many reports, and each report has a different meaning.
4. GDSII generation is the final layout output of the flow.
5. DRC, LVS, and antenna checks are essential for physical validation.
6. A simple design should be used to validate the toolchain before implementing complex hardware.
```

---

## 23. Role Of Project 0 In The Full Roadmap

Project 0 is the foundation for all later projects.

The later roadmap includes:

```text
fixed-point arithmetic primitives
SC f and g units
Polar Encoder N=8
SC Decoder N=4
SC Decoder N=8
scheduled SC decoder architecture
resource-shared SC decoder architecture
OpenLane physical implementation
```

Without Project 0, it would be difficult to distinguish between:

```text
a real RTL design bug
a testbench bug
a synthesis problem
a tool setup problem
an OpenLane configuration problem
a physical design issue
```

---

## 24. What This Project Is Not

Project 0 is not a research contribution by itself.

It should not be presented as:

```text
a novel counter design
an optimized ASIC architecture
a publication-level technical contribution
```

Instead, it should be presented as:

```text
a toolchain validation project
an introductory RTL-to-GDSII lab
a foundation for later ASIC-ready decoder projects
```

---

## 25. Conclusion

Project 0 establishes the basic RTL-to-GDSII flow using a simple counter design.

It confirms that the development environment can support:

```text
Verilog RTL design
simulation
Yosys synthesis
OpenLane physical implementation
GDSII generation
DRC/LVS/Antenna signoff
```

This project is an essential training and infrastructure milestone.

The next step is to build fixed-point arithmetic primitives that will later be used in SC Polar decoder hardware.
EOF