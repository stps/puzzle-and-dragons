import lc3b_types::*;

module forwarding_unit
(
    input logic ex_mem_load_regfile,
    input logic mem_wb_load_regfile,
    input lc3b_opcode opcode,
    input lc3b_reg ex_mem_dr_out,
    input lc3b_reg mem_wb_dr_out,
    input lc3b_reg de_ex_rs_out,
    input lc3b_reg de_ex_rt_out,
	 
	 input logic de_ex_valid_out,
	 input logic ex_mem_valid_out,
	 input logic mem_wb_valid_out,
	 input logic is_nop,

    output logic [1:0] forwardA_mux_sel,
    output logic [1:0] forwardB_mux_sel
);

always_comb
begin
	 if (ex_mem_valid_out && de_ex_valid_out)
	 begin
	 
    if (mem_wb_load_regfile && ex_mem_dr_out != de_ex_rs_out && ((mem_wb_dr_out == de_ex_rs_out) && mem_wb_valid_out))
		forwardA_mux_sel = 2'b01;
    else if (ex_mem_load_regfile && ex_mem_dr_out == de_ex_rs_out && ~is_nop)
		forwardA_mux_sel = 2'b10;
    else 
		forwardA_mux_sel = 2'b00;
	end
	
	else
		forwardA_mux_sel = 2'b00;

	if (ex_mem_valid_out && de_ex_valid_out)
	begin
    if (mem_wb_load_regfile && ex_mem_dr_out != de_ex_rt_out && ((mem_wb_dr_out == de_ex_rt_out) && mem_wb_valid_out))
		forwardB_mux_sel = 2'b01;
    else if (ex_mem_load_regfile && ex_mem_dr_out == de_ex_rt_out)
		forwardB_mux_sel = 2'b10;
    else 
		forwardB_mux_sel = 2'b00;
	end
	
	else
		forwardB_mux_sel = 2'b00;
end

endmodule : forwarding_unit