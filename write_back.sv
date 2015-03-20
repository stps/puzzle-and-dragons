import lc3b_types::*;

module write_back
(
    input clk,
    
    input lc3b_word mem_address,
    input lc3b_word data,
    input lc3b_control_word cw,
    input lc3b_word npc,
    input lc3b_word result,
    input lc3b_word ir,
    //input logic [2:0] dr,
    input logic valid,
    
    output lc3b_word gencc_out,
    output lc3b_word reg_data,
    output lc3b_reg dest_reg
);

lc3b_word drmux_out;

assign reg_data = drmux_out;

mux4 drmux
(
    .sel(cw.drmux_sel),
    .a(mem_address),
    .b(data),
    .c(new_pc),
    .d(result),
    .out(drmux_out)
);

gencc cc_logic
(
    .in(drmux_out),
    .out(gencc_out)
);

endmodule : write_back
