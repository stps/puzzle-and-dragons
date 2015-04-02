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
				
         end
endmodule : pc_logic