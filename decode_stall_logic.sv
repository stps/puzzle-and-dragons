import lc3b_types::*;

module decode_stall_logic
(
	input logic dep_stall,
	input logic decode_br_stall,
	input logic execute_br_stall,
	input logic execute_indirect_stall,
	input logic mem_stall,
	input logic mem_br_stall,
	input logic icache_stall_int,
	input logic valid_in,
	
	input logic leapfrog_load,
	input logic leapfrog_stall,
	
	output logic valid,
	output logic load_ex
);

always_comb
begin
	
	load_ex = 1'b1; // by default, continue
	valid = 1'b1;

	if (decode_br_stall == 1'b1)
	begin
	end
	
	if (dep_stall == 1'b1) // insert bubble into ex
	begin
		load_ex = 1'b1;
		valid = 1'b0;
	end
	
	if (execute_br_stall == 1'b1) // keep inserting bubbles for branch
	begin
		load_ex = 1'b1;
		valid = 1'b0;
	end
	
	if (mem_stall == 1'b1 && leapfrog_load == 1'b0) // stall everything except WB, insert bubbles in WB
	begin
		load_ex = 1'b0;
		valid = 1'b0;
	end
	
	if (leapfrog_stall == 1'b1)	// something is in memory and it can't be leapfrogged
	begin
		load_ex = 1'b0;
		valid = 1'b0;
	end
	
	if (execute_indirect_stall == 1'b1) // stall fetch and decode while EX inserts bubble for STI/LDI
	begin
		load_ex = 1'b0;
		valid = 1'b0;
	end

	if (mem_br_stall == 1'b1)
	begin
	end
	
	if (icache_stall_int == 1'b1) // while waiting for cache miss, just stall fetch
	begin
		load_ex = 1'b0;
		valid = 1'b0;
	end
	
	if (valid_in == 1'b0)
		valid = 1'b0;
end

endmodule : decode_stall_logic