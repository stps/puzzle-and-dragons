import lc3b_types::*;

module execute
(
    input clock,
    
    input lc3b_word new_pc_in,
    input lc3b_control_word cw_in,
    input lc3b_word ir_in,
    input lc3b_word sr1,
    input lc3b_word sr2,
    input logic [2:0] cc_in,
    input logic [2:0] dr_in,
    input logic valid_in,
    
    output lc3b_word mem_address,
    output lc3b_control_word cw,
    output lc3b_word new_pc,
    output lc3b_word cc,
    output lc3b_word alu_out,
    output lc3b_word ir,
    output lc3b_word dr,
    output lc3b_word valid
);

lc3b_word addr1mux_out;
lc3b_word addr2mux_out;
lc3b_word memaddrmux_out;
lc3b_word sr2mux;
lc3b_word adj6_out;
lc3b_word adj9_out;
lc3b_word adj11_out;
lc3b_word zadj_out;
lc3b_word adder_out;
lc3b_word sext_out;

mux2 addr1mux
(
    .sel(cw_in.addr1mux_sel),
    .a(new_pc_in),
    .b(sr1),
    .out(addr1mux_out)
);

mux2 memaddrmux
(
    .sel(cw_in.memaddrmux_sel),
    .a(zadj_out),
    .b(adder_out),
    .out(memaddrmux_out)
);

mux2 sr2mux
(
    .sel(cw_in.sr2mux_sel),
    .a(sr2),
    .b(sext_out),
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

adder adder
(
    .in1(addr1mux_out),
    .in2(addr2mux_out),
    .out(adder_out)
);

sext #(.width(5)) sext
(
    .in(ir_in[4:0]),
    .out(sext_out)
);

alu alu
(
    .aluop(cw_in.aluop),
    .a(sr1),
    .b(sr2mux_out),
    .f(alu_out)
);

/* todo: logic blocks */

endmodule : execute
