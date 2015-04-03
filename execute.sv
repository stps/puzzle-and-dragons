import lc3b_types::*;

module execute
(
    input clk,
    
    input lc3b_word npc_in,
    input lc3b_control_word cw_in,
    input lc3b_word ir_in,
    input lc3b_word sr1,
    input lc3b_word sr2,
    input lc3b_nzp cc_in,
    input lc3b_reg dr_in,
    input logic valid_in,
	 
	 input logic dep_stall,
	 input logic decode_br_stall,
	 input logic mem_stall,
	 input logic mem_br_stall,
	 
	 input lc3b_opcode next_opcode,
    
    output lc3b_word address,
    output lc3b_control_word cw,
    output lc3b_word npc,
    output lc3b_nzp cc,
    output lc3b_word result,
    output lc3b_word ir,
    output lc3b_reg dr,
    output logic valid,
	 output logic load_mem,
    
    output logic ex_load_cc,
    output logic ex_load_regfile,
    output logic execute_br_stall,
	 output logic execute_indirect_stall
);

logic memlatch_sel;
lc3b_control_word indirect_bubble_cw;
lc3b_control_word sti_str;
lc3b_control_word ldi_ldr;

lc3b_word addr1mux_out;
lc3b_word addr2mux_out;
lc3b_word memaddrmux_out;
lc3b_word sr2mux_out;
lc3b_word alu_result;
lc3b_word adj6_out;
lc3b_word adj9_out;
lc3b_word adj11_out;
lc3b_word zadj_out;
lc3b_word adder_out;
lc3b_word sext_out;
lc3b_word sext_shf_out;
lc3b_word cond_lshf_out;

assign npc = npc_in;
assign cc = cc_in;
assign ir = ir_in;
assign dr = dr_in;
assign address = memaddrmux_out;
assign result = alu_result;

always_comb
begin
	ldi_ldr.opcode = op_ldr;
	ldi_ldr.aluop = alu_pass;
	ldi_ldr.load_cc = 1'b1;
	ldi_ldr.load_regfile = 1'b1;
	ldi_ldr.branch_stall = 1'b0;
	ldi_ldr.sr2mux_sel = 1'b0;
	ldi_ldr.mem_read = 1'b1;
	ldi_ldr.mem_write = 1'b0;
	ldi_ldr.addr1mux_sel = 1'b1;
	ldi_ldr.addr2mux_sel = 2'b01;
	ldi_ldr.drmux_sel = 2'b01;
	ldi_ldr.regfilemux_sel = 1'b0;
	ldi_ldr.memaddrmux_sel = 1'b0;
	ldi_ldr.destmux_sel = 1'b0;
	ldi_ldr.sr1_needed = 1'b1;
	ldi_ldr.sr2_needed = 1'b0;
	ldi_ldr.lshf_enable = 1'b0;
	
	sti_str.opcode = op_str;
	sti_str.aluop = alu_pass;
	sti_str.load_cc = 1'b0;
	sti_str.load_regfile = 1'b0;
	sti_str.branch_stall = 1'b0;
	sti_str.sr2mux_sel = 1'b0;
	sti_str.mem_read = 1'b0;
	sti_str.mem_write = 1'b1;
	sti_str.addr1mux_sel = 1'b1;
	sti_str.addr2mux_sel = 2'b01;
	sti_str.drmux_sel = 2'b00;
	sti_str.regfilemux_sel = 1'b0;
	sti_str.memaddrmux_sel = 1'b0;
	sti_str.destmux_sel = 1'b0;
	sti_str.sr1_needed = 1'b1;
	sti_str.sr2_needed = 1'b0;
	sti_str.lshf_enable = 1'b0;
end

always_comb
begin
	memlatch_sel = 1'b0;
	
	if (next_opcode == op_sti)
		memlatch_sel = 1'b1;
	
	/*if (cw_in.opcode == op_sti && next_opcode != op_sti)
		execute_indirect_stall = 1'b1;
	else
		execute_indirect_stall = 1'b0;*/
	
	if (next_opcode == op_sti || next_opcode == op_ldi)
		execute_indirect_stall = 1'b1;
	else 
		execute_indirect_stall = 1'b0;
		
	if (next_opcode == op_sti)
		indirect_bubble_cw = sti_str;
	else if (next_opcode == op_ldi)
		indirect_bubble_cw = ldi_ldr;
	else
		indirect_bubble_cw = cw_in;
end

mux2 #(.width($bits(lc3b_control_word)))  mem_cw_mux
(
	.sel(memlatch_sel),
	.a(cw_in),
	.b(indirect_bubble_cw),
	.out(cw)
);

mux2 addr1mux
(
    .sel(cw_in.addr1mux_sel),
    .a(npc_in),
    .b(sr1),
    .out(addr1mux_out)
);

mux2 memaddrmux
(
    .sel(cw_in.memaddrmux_sel),
    .a(adder_out),
    .b(zadj_out),
    .out(memaddrmux_out)
);

mux4 sr2mux
(
    .sel(cw_in.sr2mux_sel),
    .a(sr2),
    .b(sext_out),
	 .c(sext_shf_out),
    .out(sr2mux_out)
);

mux4 addr2mux
(
    .sel(cw_in.addr2mux_sel),
    .a(16'h0000),
    .b(adj6_out),
    .c(adj9_out),
    .d(adj11_out),
    .out(addr2mux_out)
);

adj #(.width(6)) adj6
(
    .in(ir_in[5:0]),
    .out(adj6_out)
);

adj #(.width(9)) adj9
(
    .in(ir_in[8:0]),
    .out(adj9_out)
);

adj #(.width(11)) adj11
(
    .in(ir_in[10:0]),
    .out(adj11_out)
);

zadj zadj
(
    .in(ir_in[7:0]),
    .out(zadj_out)
);

cond_lshf cond_lshf
(
    .enable(cw_in.lshf_enable),
    .in(addr2mux_out),
    .out(cond_lshf_out)
);

adder adder
(
    .in1(addr1mux_out),
    .in2(cond_lshf_out),
    .out(adder_out)
);

sext #(.width(5)) sext
(
    .in(ir_in[4:0]),
    .out(sext_out)
);

sext #(.width(4)) sext_shf
(
    .in(ir_in[3:0]),
    .out(sext_shf_out)
);

alu alu
(
    .aluop(cw_in.aluop),
    .a(sr1),
    .b(sr2mux_out),
    .f(alu_result)
);

and_gate load_cc_check
(
    .a(valid_in),
    .b(cw_in.load_cc),
    .out(ex_load_cc)
);

and_gate load_regfile_check
(
    .a(valid_in),
    .b(cw_in.load_regfile),
    .out(ex_load_regfile)
);

and_gate branch_stall_check
(
    .a(valid_in),
    .b(cw_in.branch_stall),
    .out(execute_branch_stall)
);

ex_stall_logic ex_stall_logic
(
	.dep_stall,
	.decode_br_stall,
	.execute_br_stall,
	.mem_stall,
	.mem_br_stall,
	
	.valid,
	.load_mem
);

endmodule : execute
