import lc3b_types::*;

module control_rom
(
    input lc3b_opcode opcode,
    input logic imm_check, //also determines if rshf is log or arithm
    input logic jsr_check,
    input logic rshf_check,
    output lc3b_control_word ctrl
);

always_comb
begin
	/* Default assignments */
	ctrl.opcode = opcode;
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

	/* Assign control signals based on opcode */
	case(opcode)
		 op_add: begin
			  ctrl.sr1_needed = 1'b1;
			  
			  ctrl.aluop = alu_add;
			  ctrl.load_regfile = 1'b1;
			  ctrl.drmux_sel = 2'b11;
			  ctrl.regfilemux_sel = 1'b1;
			  if(imm_check == 0) begin
					ctrl.sr2mux_sel = 2'b00;
					ctrl.sr2_needed = 1'b1;
			  end
			  else begin
					ctrl.sr2mux_sel = 2'b01;
			  end
			  ctrl.load_cc = 1'b1;
		 end
		 
		 op_and: begin
			  ctrl.sr1_needed = 1'b1;

			  ctrl.aluop = alu_and;
			  ctrl.load_regfile = 1'b1;
			  ctrl.drmux_sel = 2'b11;
			  ctrl.regfilemux_sel = 1'b1;
			  if(imm_check == 0) begin
					ctrl.sr2mux_sel = 2'b00;
					ctrl.sr2_needed = 1'b1;
			  end
			  else begin
					ctrl.sr2mux_sel = 2'b01;
			  end

			  ctrl.load_cc = 1'b1;
		 end
		 
		 op_not: begin
			  ctrl.sr1_needed = 1'b1;
			  ctrl.aluop = alu_not;
			  ctrl.load_regfile = 1'b1;
			  ctrl.load_cc = 1'b1;
			  ctrl.drmux_sel = 2'b11;
		 end
		 
		 op_ldr: begin
			  ctrl.sr1_needed = 1'b1;
			  ctrl.mem_read = 1'b1;
			  ctrl.load_regfile = 1'b1;
			  ctrl.load_cc = 1'b1;
			  ctrl.addr1mux_sel = 1'b1;
			  ctrl.addr2mux_sel = 2'b01;
			  ctrl.drmux_sel = 2'b01;
		 end
		 
		 op_str: begin
			  ctrl.sr1_needed = 1'b1;
			  ctrl.mem_write = 1'b1;
			  ctrl.addr1mux_sel = 1'b1;
			  ctrl.addr2mux_sel = 2'b01;
		 end
		 
		 op_br: begin
			  ctrl.addr1mux_sel = 1'b0;
			  ctrl.addr2mux_sel = 2'b10;
		 end

		 op_trap: begin
			  ctrl.destmux_sel = 1'b1; // R7 <= PC
			  ctrl.load_regfile = 1'b1;
			  ctrl.drmux_sel = 2'b10;
			  ctrl.memaddrmux_sel = 1'b1;
			  ctrl.mem_read = 1'b1;
		 end

		 op_jsr: begin
			  ctrl.destmux_sel = 1'b1;
			  ctrl.load_regfile = 1'b1;
			  ctrl.drmux_sel = 2'b10;
			  if(jsr_check == 1'b0) begin
					ctrl.sr1_needed = 1'b1;
					ctrl.addr1mux_sel = 1'b1;
			  end
			  else begin
					ctrl.addr2mux_sel = 2'b11;
			  end
		 end
		 
		 op_jmp: begin
			  ctrl.sr1_needed = 1'b1;
			  ctrl.addr1mux_sel = 1'b1;
			  ctrl.addr2mux_sel = 2'b00;
		 end

		 op_shf: begin
			  ctrl.sr1_needed = 1'b1;
			  if(rshf_check == 0) begin
					ctrl.aluop = alu_sll;
			  end
			  else begin
					if(imm_check == 0)
						 ctrl.aluop = alu_srl;
					else ctrl.aluop = alu_sra;
			  end
			  ctrl.load_regfile = 1'b1;
			  ctrl.load_cc = 1'b1;
			  ctrl.drmux_sel = 2'b11;
			  ctrl.sr2mux_sel = 2'b10;
		 end
		 
		 op_lea: begin
			  ctrl.addr1mux_sel = 1'b0;
			  ctrl.addr2mux_sel = 2'b10;
			  ctrl.drmux_sel = 2'b00;
			  ctrl.load_regfile = 1'b1;
			  ctrl.load_cc = 1'b1;
		 end
		 
		 op_ldb: begin
			  ctrl.sr1_needed = 1'b1;
			  ctrl.mem_read = 1'b1;
			  ctrl.lshf_enable = 1'b1;
			  ctrl.addr1mux_sel = 1'b1;
			  ctrl.addr2mux_sel = 2'b01;
			  ctrl.load_regfile = 1'b1;
			  ctrl.load_cc = 1'b1;
			  ctrl.drmux_sel = 2'b01;
		 end
		 
		 op_ldi: begin
			  ctrl.sr1_needed = 1'b1;
			  ctrl.mem_read = 1'b1;
			  ctrl.load_regfile = 1'b1;
			  ctrl.load_cc = 1'b1;
			  ctrl.addr1mux_sel = 1'b1;
			  ctrl.addr2mux_sel = 2'b01;
			  ctrl.drmux_sel = 2'b01;
		 end
		 
		 op_stb: begin
			  ctrl.sr1_needed = 1'b1;
			  ctrl.mem_write = 1'b1;
			  ctrl.lshf_enable = 1'b1;
			  ctrl.addr1mux_sel = 1'b1;
			  ctrl.addr2mux_sel = 2'b01;
		 end
		 
		 op_sti: begin
			  ctrl.sr1_needed = 1'b1;
			  ctrl.mem_read = 1'b1;
			  ctrl.addr1mux_sel = 1'b1;
			  ctrl.addr2mux_sel = 2'b01;
			  ctrl.aluop = alu_pass;
		 end
		 
		 default: begin
			  ctrl = 0; /* Unknown opcode, set control word to zero */
		 end
	endcase
end

endmodule : control_rom