`include "memory_tb.sv"
`include "driver.sv"

`define ADDR 10
`define DATA 8

interface intf (input wire pclk);
 
    logic preset_n;
    logic psel;
    logic [`ADDR-1:0] paddr;
    logic penable;
    logic pwrite;
    logic [`DATA-1:0] pwdata;
    
    logic pready;
    logic [`DATA-1:0] prdata;
    
    logic [`ADDR-1:0] addr;
    logic [`DATA-1:0] data;
    
    logic [1:0] state;
    logic [1:0] trans_type;

    modport memory_if (input pclk, preset_n, psel, paddr, penable, pwrite, pwdata, output pready, prdata);
    modport driver (input pclk, pready, prdata, addr, data, trans_type, output state, preset_n, psel, paddr, penable, pwrite, pwdata);
    modport testbench (input pclk, state, pready, prdata, output addr, data, trans_type);
endinterface

module top_module();

    logic pclk = 0;
    always #10 pclk = ~pclk;

    intf mem_interface(pclk);
    memory #(.ADDR(`ADDR), .DATA(`DATA)) uut_memory (mem_interface);
    driver #(.ADDR(`ADDR), .DATA(`DATA)) uut_driver (mem_interface);
    memory_tb #(.ADDR(`ADDR), .DATA(`DATA)) uut_memory_tb (mem_interface);
endmodule