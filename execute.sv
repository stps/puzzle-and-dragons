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
    output logic ex_branch_stall,
);

lc3b_word addr1mux_out;
lc3b_word addr2mux_out;
lc3b_word sr2mux_out;
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
assign cw = cw_in;

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
    .out(address)
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
    .f(result)
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
    .out(ex_branch_stall)
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
