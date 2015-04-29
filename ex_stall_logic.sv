import lc3b_types::*;

module ex_stall_logic
(
	input logic dep_stall,
	input logic decode_br_stall,
	input logic execute_br_stall,
	input logic mem_stall,
	input logic mem_br_stall,
	input logic icache_stall_int,
	input logic valid_in,
	input logic execute_indirect_stall,
	
	input logic leapfrog_load,
	input logic leapfrog_stall,
	
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
	
	if (mem_stall == 1'b1 && leapfrog_load == 1'b0) // fix pls
	begin
		load_mem = 1'b0;
		valid = 1'b0;
	end
				
	if (leapfrog_stall == 1'b1) // something is in memory and it can't be leapfrogged
	begin
		load_mem = 1'b0;
		valid = 1'b0;
	end
	
	if (mem_br_stall == 1'b1)
	begin
	end
	
	if (icache_stall_int == 1'b1) // while waiting for cache miss, just stall fetch
	begin
		load_mem = 1'b0;
		valid = 1'b0;
	end
	
	if (valid_in == 1'b0)
		valid = 1'b0;
		
//	if (execute_indirect_stall == 1'b1)
//		valid = 1'b1;
		
	if (leapfrog_load == 1'b1)
		load_mem = 1'b0;
end

endmodule : ex_stall_logic