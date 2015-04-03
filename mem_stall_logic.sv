import lc3b_types::*;

module mem_stall_logic
(
	input logic dep_stall,
	input logic decode_br_stall,
	input logic execute_br_stall,
	input logic mem_stall,
	input logic mem_br_stall,
	input logic dcache_resp,
	
	output logic valid,
	output logic load_wb
);
always_comb
begin
	
	load_wb = 1'b1; // by default, continue
	valid = 1'b1;

	if (mem_stall == 1'b1) // stall everything except WB, insert bubbles in WB
	begin
		load_wb = 1'b1;
		valid = 1'b0;
	end

	if (decode_br_stall == 1'b1) // only needs to stall frontend of pipeline, MEM can continue
	begin
		load_wb = 1'b1;
		valid = 1'b1;
	end
	
	if (dep_stall == 1'b1) // mem can and needs to continue to clear dependency
	begin
		load_wb = 1'b1;
		valid = 1'b1;
	end
	
	if (execute_br_stall == 1'b1) // mem can continue
	begin
		load_wb = 1'b1;
		valid = 1'b1;
	end
	
	if (mem_br_stall == 1'b1) // MEM keeps working, frontend stalls, fetch inserts bubbles
	begin
	end
	
	if (dcache_resp == 1'b0) // while waiting for cache miss, just stall mem
	begin
		load_wb = 1'b0;
		valid = 1'b0;
	end
	
end

endmodule : mem_stall_logic