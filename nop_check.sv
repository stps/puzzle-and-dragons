import lc3b_types::*;

module nop_check
(
	input lc3b_word instruction,
	input lc3b_control_word cw_rom,
	output lc3b_control_word ctrl
	
);

always_comb
begin
	if (instruction == 16'b0000000000000000)
	begin
	
		ctrl.opcode = op_br;
		ctrl.aluop = alu_pass;
		ctrl.load_cc = 1'b0;
		ctrl.load_regfile = 1'b0;
		ctrl.branch_stall = 1'b0;
		ctrl.sr2mux_sel = 2'b00;
		ctrl.mem_read = 1'b0;
		ctrl.mem_write = 1'b0;
		ctrl.addr1mux_sel = 1'b0;
		ctrl.addr2mux_sel = 2'b00;
		ctrl.drmux_sel = 2'b00;
		ctrl.regfilemux_sel = 1'b0;
		ctrl.memaddrmux_sel = 1'b0;
		ctrl.destmux_sel = 1'b0;
		ctrl.indirectaddrmux_sel = 1'b0;
		ctrl.sr1_needed = 1'b0;
		ctrl.sr2_needed = 1'b0;
		ctrl.lshf_enable = 1'b0;
		ctrl.is_nop = 1'b1;
	
	end
	else
		ctrl = cw_rom;
end

endmodule : nop_check