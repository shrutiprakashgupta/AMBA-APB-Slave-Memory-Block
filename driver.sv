module driver #(parameter  ADDR = 10, DATA=8) (intf.driver drv);

wire [1:0] next_state;
parameter init = 0, start = 1, transfer = 2, done = 3;
  
//0 - init, 1 - read, 2 - write, 3 - stop
function logic[1:0] next(input reg[1:0] state, reg[1:0] trans_type);
    case(state)
      init : case (trans_type)
        		0 : next = init;
        		3 : next = done;
        		default : next = start;
      		endcase 
      start : case (trans_type)
        		0 : next = init;
        		3 : next = done;
        		default : next = transfer;
      		endcase 
      transfer : case (trans_type)
        		0 : next = init;
        		3 : next = done;
        		default : next = start;
      		endcase 
      done : case (trans_type)
        		0 : next = init;
        		3 : next = done;
        		default : next = start;
      		endcase 
      default : next = init;
    endcase
endfunction     

assign next_state = next(drv.state, drv.trans_type); 

always @(negedge drv.pclk) begin
    if(next_state==init) begin
        drv.preset_n <= 0;
        drv.psel <= 0;
        drv.paddr <= 0;
        drv.penable <= 0;
        drv.pwrite <= 0;
        drv.pwdata <= 0;
    end
    else begin
        if(next_state==start) begin
            drv.preset_n <= 1; 
            drv.psel  <= 1;
            drv.paddr <= drv.addr;
            drv.penable <= 0;
            drv.pwrite <= drv.trans_type[1];
            drv.pwdata <= drv.data;
        end
        else begin 
            if(next_state==transfer) begin
                drv.preset_n <= 1; 
                drv.psel <= 1; 
                drv.paddr <= drv.addr; 
                drv.penable <= 1;
                drv.pwrite <= drv.trans_type[1];
                drv.pwdata <= drv.data;
            end
            else begin
                drv.preset_n <= 1;
                drv.psel <= 0;
                drv.paddr <= 0;
                drv.penable <= 0;
                drv.pwrite <= 0;
                drv.pwdata <= 0;
            end 
        end
    end
drv.state <= next_state;
end
endmodule