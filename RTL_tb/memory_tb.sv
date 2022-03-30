`define ADDR 10
`define DATA 8

class transaction_type;
    rand logic [`ADDR-1:0] paddr;
    rand logic [`DATA-1:0] pwdata;
  	rand logic [1:0]trans_type; 
    //Transaction type: 0 - Reset
    //                  1 - Read Transaction 
    //                  2 - Write Transaction
    //                  3 - No transaction

    constraint align_addr {paddr[1:0] == 2'b00;}
    constraint activity {trans_type dist {1 := 2, 2 := 8, 3 := 1};}
endclass


class stimulus;
    logic [`ADDR-1:0] paddr;
    logic [`DATA-1:0] pwdata;
    logic [1:0] trans_type;     
endclass

typedef mailbox #(stimulus) io_mailbox;
io_mailbox trans = new(20);
event trigger_complete;

task send(stimulus io);
  trans.put(io);
endtask

module memory_tb #(parameter  ADDR = 10, DATA=8) (intf.testbench tbif);
parameter init = 0, start = 1, transfer = 2, done = 3;
	transaction_type trans_obj;
    stimulus io, trigger;
      
  	initial begin 
      $dumpfile("waveform.vcd");
      $dumpvars(50,top_module);
    end
    initial begin 
      	
      	trans_obj = new();
      	io = new();
     	trigger = new();

        trans_obj.randomize();
        io.paddr = trans_obj.paddr;
        io.pwdata = trans_obj.pwdata;
        //Reset
        io.trans_type = 0;
        
        send(io);
      	trans.get(io);
        tbif.addr <= io.paddr;
        tbif.data <= io.pwdata;
        tbif.trans_type <= io.trans_type;    
      	
        repeat(20) begin
          	io = new();
            assert(trans_obj.randomize());
			io.paddr = trans_obj.paddr;
            io.pwdata = trans_obj.pwdata;
            io.trans_type = trans_obj.trans_type;
        	
            send(io);
        end
      	$display("All stimulus generated at %0t", $time());
        @trigger_complete;
        $finish();
    end 

    always @(posedge tbif.pclk) begin
        if((tbif.state == init) | (tbif.state == transfer) | (tbif.state == done)) begin
        trans.get(io);
        tbif.addr <= io.paddr;
        tbif.data <= io.pwdata;
        tbif.trans_type <= io.trans_type;
        if(trans.num() == 0) begin
          	#50;
          	->trigger_complete;
        end
        end    
    end

    always @(negedge tbif.pclk) begin
      	if(tbif.state == transfer) 
          $display("[%0t] Read: PREADY: %d, PWDATA: %d", $time(), tbif.pready, tbif.prdata);
    end
endmodule