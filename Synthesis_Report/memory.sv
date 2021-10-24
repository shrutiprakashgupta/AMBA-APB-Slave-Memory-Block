module memory #(parameter  ADDR = 10, DATA=32) (pclk, preset_n, psel, paddr, penable, pwrite, pwdata, pready, prdata);

input pclk;
input preset_n;
input psel;
input [ADDR-1:0] paddr;
input penable;
input pwrite;
input [DATA-1:0] pwdata;
    
output pready;
output reg [DATA-1:0] prdata;
    
integer i;
parameter mem_size = 1<<ADDR;
reg [31:0] memory_1k32 [mem_size];

wire active;
  
assign pready = 1'b1;
// For periferals which guarentee transfer in 2 cycles, pready can be tied high
assign active = penable & pready;

always @(posedge pclk) begin

    if(preset_n == 1'b0) begin
        prdata <= 0;
        for(i=0; i<mem_size; i=i+1) begin
          memory_1k32[i] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
        end
    end    
    else begin
        if(psel == 1'b1) begin
            if(active == 1'b1) begin
                if (pwrite == 1'b1) begin
                  for(i=0; i<DATA; i=i+1) begin
                    memory_1k32[paddr][i] <= pwdata[i];
                  end
                end
                else begin
                  for(i=0; i<DATA; i=i+1) begin
                    prdata[i] <= memory_1k32[paddr][i];
                  end
                end
            end
        end
    end
end

endmodule
