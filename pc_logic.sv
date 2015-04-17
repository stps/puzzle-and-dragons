import lc3b_types::*;

module pc_logic
(
	input logic dep_stall,
	input logic decode_br_stall,
	input logic execute_br_stall,
	input logic mem_stall,
	input logic mem_br_stall,
	
	input logic icache_stall_int,
	input logic mem_valid_in,
	input logic [1:0] pc_mux_sel,
	
	output logic ld_pc
);
         always_comb
         begin
				if (mem_valid_in == 1'b0 && pc_mux_sel == 1'b1)
					ld_pc = 1'b0;
				
				else
				begin
					if (dep_stall == 1'b1 || decode_br_stall == 1'b1 || execute_br_stall == 1'b1 || mem_stall == 1'b1 || mem_br_stall == 1'b1 || icache_stall_int == 1'b1)
					begin	
						ld_pc = 1'b0;
						if (pc_mux_sel == 2'b10 || pc_mux_sel == 2'b01)
							ld_pc = 1'b1;
					end
					else
						ld_pc = 1'b1;
				end
				
         end
endmodule : pc_logic