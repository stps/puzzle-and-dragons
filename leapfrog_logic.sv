import lc3b_types::*;

module leapfrog_logic
(
	input logic mem_stall,
	input lc3b_control_word cw,
	input lc3b_reg mem_dr,
	input lc3b_reg sr1,
	input lc3b_reg sr2,
	
	input logic wb_ld_cc,
	// need to stall if branch while something in mem, UNLESS something else set CCs since
	input logic valid_in,
	
	output logic leapfrog_load,
	output logic leapfrog_stall
);



always_comb
begin
	leapfrog_load = 1'b0;
	leapfrog_stall = 1'b0;
	
	if (mem_stall == 1'b1)
	begin
		leapfrog_load = 1'b1;
		leapfrog_stall = 1'b0;
		
		if ((mem_dr == sr1 && cw.sr1_needed == 1'b1) || (mem_dr == sr2 && cw.sr2_needed == 1'b1) || cw.opcode == op_ldr || cw.opcode == op_ldi || cw.opcode == op_lea || cw.opcode == op_str || cw.opcode == op_sti)
		begin
			leapfrog_load = 1'b0;
			leapfrog_stall = 1'b1;
		end
		
		if (cw.opcode == op_trap)
		begin
			leapfrog_load = 1'b0;
			leapfrog_stall = 1'b1;
		end
		
		if (cw.opcode == op_br && cw.branch_stall == 1'b1) // need to account for unconditional branch
		begin
			leapfrog_load = 1'b0;
			leapfrog_stall = 1'b1;
			if (wb_ld_cc)
			begin
				leapfrog_load = 1'b1;
				leapfrog_stall = 1'b0;
			end // prob need more edge cases for if cc changed but by something earlier and not still in WB
		end
		
		if (valid_in == 1'b0)
		begin
			leapfrog_load = 1'b1;
			leapfrog_stall = 1'b0;
		end
		
	end
end

endmodule : leapfrog_logic