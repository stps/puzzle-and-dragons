import lc3b_types::*;

module mem_stall_logic
(
	input mem_read,
	input mem_write,
	input dep_stall,
	input decode_br_stall,
	input execute_br_stall,
	input mem_br_stall,
	input dcache_resp,
	
	output logic valid,
	output logic load_wb,
	output logic mem_stall
);

logic mem_stall_int;

always_comb
begin
	
	load_wb = 1'b1; // by default, continue
	valid = 1'b1;
	mem_stall_int = 1'b0;
	
	if (dcache_resp == 1'b0 && (mem_read || mem_write)) // while waiting for cache miss, just stall mem
	begin
		mem_stall_int = 1'b1;
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
	
	if (mem_stall_int == 1'b1) // stall everything except WB, insert bubbles in WB
	begin
		load_wb = 1'b1;
		valid = 1'b0;
	end
	
	mem_stall = mem_stall_int;
end

endmodule : mem_stall_logic