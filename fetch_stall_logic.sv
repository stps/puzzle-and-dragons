import lc3b_types::*;

module fetch_stall_logic
(
	input logic dep_stall,
	input logic decode_br_stall,
	input logic execute_br_stall,
	input logic mem_stall,
	input logic mem_br_stall,
	
	input logic icache_resp,
	
	output logic valid,
	output logic load_de
);
         always_comb
         begin
				if (decode_br_stall == 1'b1) // DE stage tells fetch to insert bubbles until the PC is updated in MEM
				begin
					load_de = 1'b1;
					valid = 1'b0;
				end
				
				else if (dep_stall == 1'b1) // DE stage tells fetch to stall, and EX to insert bubbles
				begin
					load_de = 1'b0;
					valid = 1'b0;
				end
				
				else if (execute_br_stall == 1'b1) // control instruction still propogating, still insert bubbles
				begin
					load_de = 1'b1;
					valid = 1'b0;
				end
				
				else if (mem_stall == 1'b1) // stall everything except WB, insert bubbles in WB
				begin
					load_de = 1'b0;
					valid = 1'b0;
				end
				
				else if (mem_br_stall == 1'b1) // control instruction still propogating, still insert bubble
				begin
					load_de = 1'b1;
					valid = 1'b0;
				end
				
				else if (icache_resp == 1'b0) // while waiting for cache miss, just stall fetch
				begin
					load_de = 1'b0;
					valid = 1'b0;
				end
				
				else // otherwise everything is fine
				begin
					load_de = 1'b1;
					valid = 1'b1;
				end
         end
endmodule : fetch_stall_logic