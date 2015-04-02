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
				if (dep_stall == 1'b1 || decode_br_stall == 1'b1 || execute_br_stall == 1'b1 || mem_stall == 1'b1 || mem_br_stall == 1'b1 || icache_resp == 1'b0)
				begin
					load_de = 1'b0;
				end
				else
				begin
					load_de = 1'b1;
				end
         end
endmodule : fetch_stall_logic