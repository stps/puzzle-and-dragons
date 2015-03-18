import lc3b_types::*;

module write_back
(
    input clock,
    
    input lc3b_word mem_address,
    input lc3b_word data,
    input lc3b_control_word cw,
    input lc3b_word new_pc,
    input lc3b_word alu_out,
    input lc3b_word ir,
    //input logic [2:0] dr,
    input logic valid,
    
    output lc3b_word gencc_out
);

lc3b_word drmux_out;

/*logic_block
(
);*/

mux4 drmux
(
    .sel(cw.drmux_sel)
    .a(mem_address),
    .b(data),
    .c(new_pc),
    .d(alu_out),
    .out(drmux_out)
);

gencc cc_logic
(
    .in(drmux_out),
    .out(gencc_out)
);

endmodule : write_back
