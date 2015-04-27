import lc3b_types::*;

module fetch_stall_logic
(
	input logic dep_stall,
	input logic decode_br_stall,
	input logic execute_br_stall,
	input logic execute_indirect_stall,
	input logic mem_stall,
	input logic mem_br_stall,
	
	input logic icache_read,
	input logic icache_resp,
	
	input logic leapfrog_load,
	input logic leapfrog_stall,
	
	output logic valid,
	output logic load_de,
	output logic icache_stall_int
);


         always_comb
         begin
			
				load_de = 1'b1; // by default, continue
				valid = 1'b1;
				icache_stall_int = 1'b0;
				
				if (icache_resp == 1'b0 && icache_read == 1'b1) // while waiting for cache miss, just stall fetch
				begin
					icache_stall_int = 1'b1;
				end
				
				if (decode_br_stall == 1'b1) // DE stage tells fetch to insert bubbles until the PC is updated in MEM
				begin
					load_de = 1'b1;
					valid = 1'b0;
				end
				
				if (execute_br_stall == 1'b1) // control instruction still propogating, still insert bubbles
				begin
					load_de = 1'b1;
					valid = 1'b0;
				end
				
				if (mem_br_stall == 1'b1) // control instruction still propogating, still insert bubble
				begin
					load_de = 1'b1;
					valid = 1'b0;
				end
				
				if (mem_stall == 1'b1 && leapfrog_load == 1'b0) // stall everything except WB, insert bubbles in WB
				begin
					load_de = 1'b0;
					valid = 1'b0;
				end
	
				if (leapfrog_stall == 1'b1) // something is in memory and it can't be leapfrogged
				begin
					load_de = 1'b0;
					valid = 1'b0;
				end
				
				if (execute_indirect_stall == 1'b1) // stall fetch and decode while EX inserts bubble for STI/LDI
				begin
					load_de = 1'b0;
					valid = 1'b0;
				end
				
				if (dep_stall == 1'b1) // DE stage tells fetch to stall, and EX to insert bubbles
				begin
					load_de = 1'b0;
					valid = 1'b0;
				end
				
				if (icache_stall_int == 1'b1) // while waiting for cache miss, just stall fetch
				begin
					load_de = 1'b0;
					valid = 1'b0;
				end
         end
endmodule : fetch_stall_logic