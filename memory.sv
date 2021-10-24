module memory #(parameter  ADDR = 10, DATA=8) (intf.memory_if mif);

integer i;
parameter mem_size = 1<<ADDR;
reg [31:0] memory_1k32 [mem_size];

wire active;
  
assign mif.pready = 1'b1;
// For periferals which guarentee transfer in 2 cycles, pready can be tied high
assign active = mif.penable & mif.pready;

always @(posedge mif.pclk) begin

    if(mif.preset_n == 1'b0) begin
        mif.prdata <= 0;
        for(i=0; i<mem_size; i=i+1) begin
          //memory_1k32[i] <= '{32{0}};
          memory_1k32[i] <= i;
        end
    end    
    else begin
        if(mif.psel == 1'b1) begin
            if(active == 1'b1) begin
                if (mif.pwrite == 1'b1) begin
                  for(i=0; i<DATA; i=i+1) begin
                    memory_1k32[mif.paddr][i] <= mif.pwdata[i];
                  end
                  $display("[%0t] Write: ADDR: %d, DATA: %d",$time(),mif.paddr,memory_1k32[mif.paddr]);
                end
                else begin
                  for(i=0; i<DATA; i=i+1) begin
                    mif.prdata[i] <= memory_1k32[mif.paddr][i];
                  end
                end
            end
        end
    end
end

endmodule