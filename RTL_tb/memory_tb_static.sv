// Code your testbench here
// or browse Examples
`define DATA 8
`define ADDR 10

module memory_tb ();
    reg pclk;
    reg present_n;
    reg psel;
    reg [`ADDR-1:0] paddr;
    reg penable;
    reg pwrite;
    reg [`DATA-1:0] pwdata;

    wire pready;
    wire [`DATA-1:0] prdata;

    memory uut (.pclk(pclk), .present_n(present_n), .psel(psel), .paddr(paddr), .penable(penable), .pwrite(pwrite), .pwdata(pwdata), .pready(pready), .prdata(prdata));
    always #5 pclk <= !pclk;

    task show();
        #10;
      $display("[%0t] RESET: %d, PSEL: %d, ADDR: %d, ENABLE: %d, WRITE: %d, DATA: %d, READY: %d, READ_DATA: %d", $time(), present_n, psel, paddr, penable, pwrite, pwdata, pready, prdata);
    endtask 

    initial begin 
        pclk <= 1'b0;
      present_n <= 0; psel <= 0; paddr <= 0; penable <= 0; pwrite <= 0; pwdata <= 0;
        show();
        present_n <= 1; psel <= 0; paddr <= 0; penable <= 0; pwrite <= 0; pwdata <= 0;
        show();
        present_n <= 1; psel <= 1; paddr <= 0; penable <= 0; pwrite <= 0; pwdata <= 0;
        show();
        present_n <= 1; psel <= 1; paddr <= 16; penable <= 1; pwrite <= 1; pwdata <= 32;
        show();
        present_n <= 1; psel <= 1; paddr <= 24; penable <= 1; pwrite <= 1; pwdata <= 17;
        show();
        present_n <= 1; psel <= 1; paddr <= 16; penable <= 1; pwrite <= 0; pwdata <= 0;
        show();
        present_n <= 1; psel <= 0; paddr <= 0; penable <= 1; pwrite <= 0; pwdata <= 0;
        show();  
        $finish();
    end
endmodule