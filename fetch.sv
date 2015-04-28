import lc3b_types::*;

module fetch
(
	input clk,
	input logic [1:0] pc_mux_sel,
	input lc3b_word trap_pc,
	input lc3b_word target_pc,
	input logic load_regs,

	//stall signals
	input logic dep_stall,
	input logic decode_br_stall,
	input logic execute_br_stall,
	input logic execute_indirect_stall,
	input logic mem_stall,
	input logic mem_br_stall,

	//need to connect to icache
	input lc3b_word icache_rdata,
	input logic icache_resp,
	input logic mem_valid_in,
	
	input logic leapfrog_load,
	input logic leapfrog_stall,

	output lc3b_word icache_address,
	output logic icache_read,
	output logic icache_stall_int,

	output lc3b_word new_pc,
	output lc3b_word ir,
	output logic valid, //set to 0 if icache gives garbage and not stalling for other reason
	output logic load_de
);

logic ld_pc;

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

pc_logic pc_logic
(
	.dep_stall,
	.decode_br_stall,
	.execute_br_stall,
	.mem_stall,
	.mem_br_stall,
	.leapfrog_load,
	.leapfrog_stall,
	.icache_stall_int,
	.mem_valid_in,
	.pc_mux_sel,
	.ld_pc
);

assign icache_address = pc_out;
assign icache_read = 1'b1;
assign ir = icache_rdata;

fetch_stall_logic fetch_stall_logic
(
	.dep_stall,
	.decode_br_stall,
	.execute_br_stall,
	.execute_indirect_stall,
	.mem_stall,
	.mem_br_stall,
	
	.icache_read,
	.icache_resp,
	
	.leapfrog_load,
	.leapfrog_stall,
	
	.valid,
	.load_de,
	.icache_stall_int
);

endmodule : fetch
