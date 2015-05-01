import lc3b_types::*;

module dep_check_logic
(
	input lc3b_reg sr1,
	input lc3b_reg sr2,
	input logic valid,
	
	input logic sr1_needed,
	input logic sr2_needed,
	input lc3b_control_word cw,
	
	input logic leapfrog_load,
	
	input logic ex_ld_cc,
	input logic mem_ld_cc,
	input logic wb_ld_cc,
	
	input lc3b_reg ex_drid,
	input lc3b_reg mem_drid,
	input lc3b_reg wb_drid,
	
	input logic ex_ld_reg,
	input logic mem_ld_reg,
	input logic wb_ld_reg,
	
	input logic ex_valid,
	input logic mem_valid,
	input logic wb_valid,
	
	output logic dep_stall
	
);

always_comb
begin
	dep_stall = 1'b0;
	if (valid == 1'b1)
	begin
	
		if (sr1_needed  == 1'b1)
		begin
			if (ex_ld_reg == 1'b1)
			begin
				if (ex_drid == sr1 && ex_valid == 1'b1)
					dep_stall = 1'b1;
			end
			
			if (mem_ld_reg  == 1'b1)
			begin
				if (mem_drid == sr1 && mem_valid == 1'b1)
					dep_stall = 1'b1;
			end
			
			if (wb_ld_reg == 1'b1)
			begin
				if (wb_drid == sr1 && wb_valid == 1'b1)
					dep_stall = 1'b1;
			end
		end
		
		if (sr2_needed == 1'b1)
		begin
			if (ex_ld_reg == 1'b1)
			begin
				if (ex_drid == sr2 && ex_valid == 1'b1)
					dep_stall = 1'b1;
			end
			
			if (mem_ld_reg  == 1'b1)
			begin
				if (mem_drid == sr2 && mem_valid == 1'b1)
					dep_stall = 1'b1;
			end
			
			if (wb_ld_reg == 1'b1)
			begin
				if (wb_drid == sr2 && wb_valid == 1'b1)
					dep_stall = 1'b1;
			end
		end
		
		if (cw.opcode == op_br && cw.branch_stall == 1'b1)
		begin
			if ((ex_ld_cc == 1'b1 && ex_valid) || (mem_ld_cc == 1'b1 && mem_valid) || (wb_ld_cc == 1'b1 && wb_valid))
				dep_stall = 1'b1;
//			if (ex_ld_cc == 1'b1 && ex_valid && leapfrog_load == 1'b1)
//				dep_stall = 1'b0;
		end
		
	end
end

endmodule : dep_check_logic