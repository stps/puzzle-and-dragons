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
    input logic [2:0] dr,
    input logic valid,
    
    output lc3b_nzp gencc_out,
    output lc3b_word reg_data,
    output lc3b_reg dest_reg,
    output logic ld_reg_store,
    output logic ld_cc_store
);

lc3b_word drmux_out;

assign reg_data = drmux_out;
//assign ld_reg_store = cw.load_regfile;
//assign ld_cc_store = cw.load_cc;
assign dest_reg = dr;

mux4 drmux
(
    .sel(cw.drmux_sel),
    .a(mem_address),
    .b(data),
    .c(npc),
    .d(result),
    .out(drmux_out)
);

gencc cc_logic
(
    .in(drmux_out),
    .out(gencc_out)
);

and_gate load_cc_check
(
    .a(valid),
    .b(cw.load_cc),
    .out(ld_cc_store)
);

and_gate load_regfile_check
(
    .a(valid),
    .b(cw.load_regfile),
    .out(ld_reg_store)
);

endmodule : write_back
