import lc3b_types::*;

module ex_stall_logic
(
	input logic dep_stall,
	input logic decode_br_stall,
	input logic execute_br_stall,
	input logic mem_stall,
	input logic mem_br_stall,
	
	output logic valid,
	output logic load_mem
);
         always_comb
         begin
				
				load_mem = 1'b1; // by default, continue
				valid = 1'b1;
			
				if (decode_br_stall == 1'b1)
				begin
				end
				
				if (dep_stall == 1'b1)
				begin
				end
				
				if (execute_br_stall == 1'b1)
				begin
				end
				
				if (mem_stall == 1'b1) // stall everything except WB, insert bubbles in WB
				begin
					load_mem = 1'b0;
					valid = 1'b0;
				end
				
				if (mem_br_stall == 1'b1)
				begin
				end
				
         end
endmodule : ex_stall_logic