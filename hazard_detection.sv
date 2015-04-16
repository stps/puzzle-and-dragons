import lc3b_types::*;

module hazard_detection
(

	// MEM->EX, WB->EX hazards
	input lc3b_reg de_ex_rs_out,
	input lc3b_reg de_ex_rt_out,
	input lc3b_reg mem_wb_dr_out,
	input lc3b_reg ex_mem_dr_out,
	
	// MEM->MEM hazards(ldr then str)
	//input lc3b_reg ex_mem_dr_out
	//input lc3b_reg mem_wb_dr_out
	
	output logic mem_ex_hazard,
	output logic wb_ex_hazard,
	output logic wb_mem_hazard
	
	
	// still need to check that the instructions actually write registers
);

always_comb
begin
	
	mem_ex_hazard = 1'b0;
	wb_ex_hazard = 1'b0;
	wb_mem_hazard = 1'b0;

	if (ex_mem_dr_out == de_ex_rs_out || ex_mem_dr_out == de_ex_rt_out)
		mem_ex_hazard = 1'b1;
	
	if (mem_wb_dr_out == de_ex_rs_out || mem_wb_dr_out == de_ex_rt_out)
		wb_ex_hazard = 1'b1;
		
	if (ex_mem_dr_out == mem_wb_dr_out)
		wb_mem_hazard = 1'b1; // only need if LDR after STR


end

endmodule : hazard_detection
