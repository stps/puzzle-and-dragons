import lc3b_types::*;

module dep_check_logic
(
	input lc3b_reg sr1,
	input lc3b_reg sr2,
	input logic valid,
	
	input logic sr1_needed,
	input logic sr2_needed,
	input lc3b_opcode opcode,
	
	input logic ex_ld_cc,
	input logic mem_ld_cc,
	input logic wb_ld_cc,
	
	input lc3b_reg ex_drid,
	input lc3b_reg mem_drid,
	input lc3b_reg wb_drid,
	
	input logic ex_ld_reg,
	input logic mem_ld_reg,
	input logic wb_ld_reg,
	
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
				if (ex_drid == sr1)
					dep_stall = 1'b1;
			end
			
			if (mem_ld_reg  == 1'b1)
			begin
				if (mem_drid == sr1)
					dep_stall = 1'b1;
			end
			
			if (wb_ld_reg == 1'b1)
			begin
				if (wb_drid == sr1)
					dep_stall = 1'b1;
			end
		end
		
		if (sr2_needed == 1'b1)
		begin
			if (ex_ld_reg == 1'b1)
			begin
				if (ex_drid == sr2)
					dep_stall = 1'b1;
			end
			
			if (mem_ld_reg  == 1'b1)
			begin
				if (mem_drid == sr2)
					dep_stall = 1'b1;
			end
			
			if (wb_ld_reg == 1'b1)
			begin
				if (wb_drid == sr2)
					dep_stall = 1'b1;
			end
		end
		
		if (opcode == op_br)
		begin
			if (ex_ld_cc == 1'b1 || mem_ld_cc == 1'b1 || wb_ld_cc == 1'b1)
				dep_stall = 1'b1;
		end
		
	end
end

endmodule : dep_check_logic