# AMBA-APB-Slave-Memory-Block
This repository contains the RTL model of a memory block which is enabled with a state machine which allows transactions with any Master device following the AMBA APB Module.
# Overview 
This project includes the RTL design of a Single port memory module, synchronized with the reference clock which is used by the Driver as well, for data transfer following the AMBA APB Protocol. This protocol is widely used in microcontrollers to communicate in a general setup of Master and Slave devices, where the Master can decide the module to communicate with, by pulling up the Chip enable signal corresponding to it. Each transfers completes in atleast two clock cycles. For further information on the protocol visit [this link](https://developer.arm.com/documentation/ihi0024/c).</br>
Note: AMBA - Advanced Microcontroller Bus Architecture, APB - Advanced Peripheral Bus </br>
# Testbench 
The basic RTL module is added with a randomized testbench and the Driver module. Here, the top module instantiates the [Memory module](https://github.com/shrutiprakashgupta/AMBA-APB-Slave-Memory-Block/blob/main/RTL_Src/memory.sv), [Driver module](https://github.com/shrutiprakashgupta/AMBA-APB-Slave-Memory-Block/blob/main/RTL_Src/driver.sv) and the [Testbench](https://github.com/shrutiprakashgupta/AMBA-APB-Slave-Memory-Block/blob/main/RTL_tb/memory_tb.sv). The tb generates random signals (which are constrained to valid values, like word aligned memory address) and feeds them to the driver module. The state machine inside the driver module generates the signals which are in turn fed to the memory module and perform read or write operations across it.</br>
An overview of this system is given here: ![Overview of the Project](https://github.com/shrutiprakashgupta/AMBA-APB-Slave-Memory-Block/blob/main/Synthesis_Report/Overview.png)</br>
# Synthesis
The verification modules including the Top module, Testbench and Driver are not synthesizable, however, the memory module (basic RTL block) is synthesized using the UMC 65nm technology files. Synopsys [Design Vision](http://www.eng.auburn.edu/~nelson/courses/elec5250_6250/slides/LogicSynthesis-Synopsys.pdf) is used for the synthesis and area, timing and power report generation. As the signals are taken to be directed to the memory module (and thus not clocked at the input edge) thus the design is synthesized without any timing violations at 1ns clock rate. However, if it is integrated with other periferals, this timing factor would need to be changed. 
# Execution
[Here](https://www.edaplayground.com/x/mCkg) is the link to the edaplayground where the testbench can be executed and observed.</br> 
The outputs generated from the memory are read by the testbench (monitor) back and shown on the display. As a simpler alternative, which gives a wider view over the whole process going on across the various modules, the waveform can also be observed. This is a snippet from the waveform window, which shows the functional correctness of the module ![Waveform](https://github.com/shrutiprakashgupta/AMBA-APB-Slave-Memory-Block/blob/main/Synthesis_Report/Output_Waveform.png)
