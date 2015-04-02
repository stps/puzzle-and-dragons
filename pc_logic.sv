import lc3b_types::*;

module pc_logic
(
	input logic dep_stall,
	input logic decode_br_stall,
	input logic execute_br_stall,
	input logic mem_stall,
	input logic mem_br_stall,
	
	input logic icache_resp,
	
	output logic ld_pc
);
         always_comb
         begin
				if (dep_stall == 1'b1 || decode_br_stall == 1'b1 || execute_br_stall == 1'b1 || mem_stall == 1'b1 || mem_br_stall == 1'b1 || icache_resp == 1'b0)
					ld_pc = 1'b0;
				else
					ld_pc = 1'b1;
         end
endmodule : pc_logic