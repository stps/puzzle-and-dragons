import lc3b_types::*;

module decode
(
	input clk,
	input lc3b_word npc_in,
	input lc3b_word ir_in,
	input valid_in,
	input lc3b_word reg_data,
	input lc3b_nzp cc_data,
	input lc3b_reg dest_reg,
	
	output lc3b_word npc, 
	output lc3b_control_word cw,
	output lc3b_word ir,
	output lc3b_word sr1,
	output lc3b_word sr2,
	output lc3b_nzp cc_out,
	output lc3b_reg dr,
	output logic valid
);

lc3b_reg regfilemux_out;
lc3b_reg destmux_out;

always_comb
begin
	npc = npc_in;
	ir = ir_in;
	dr = destmux_out;
end

control_rom control_store
(
    .opcode(ir_in[15:11]),
    .imm_check(ir_in[5]),
    .ctrl(cw)
);

regfile regfile_int
(
	.clk,
	.load(cw.load_regfile),
	.in(reg_data),
	.src_a(ir_in[8:6]),
	.src_b(regfilemux_out),
	.dest(dest_reg),
	.reg_a(sr1),
	.reg_b(sr2)
);

mux2 regfilemux(.a(ir_in[11:9]), .b(ir_in[2:0]), .out(regfilemux_out));
mux2 destmux(.a(ir_in[11:9]), .b(3'b111), .out(destmux_out));

register #(.width(3)) cc
(
	.clk,
	.load(cw.load_cc),
	.in(cc_data),
	.out(cc_out)
);


endmodule : decode