import lc3b_types::*;

module fetch
(
	input clk,
	input logic [1:0] pc_mux_sel,
	input lc3b_word trap_pc,
	input lc3b_word target_pc,
	input logic ld_pc,

	output lc3b_word new_pc,
	output lc3b_word ir,
	output logic valid,
	output stall
);

lc3b_word pc_mux_out;
lc3b_word pc_out;
lc3b_word plus2_out;
assign new_pc = plus2_out; 

register #(.width(16)) pc
(
	.clk,
	.load(ld_pc),
	.in(pc_mux_out),
	.out(pc_out)

);

plus2 plus2
(
	.in(pc_out),
	.out(plus2_out)
);

mux4 pc_mux
(
	.a(plus2_out),
	.b(target_pc),
	.c(trap_pc),
	.sel(pc_mux_sel),
	.out(pc_mux_out)
);




endmodule : fetch