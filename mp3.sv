import lc3b_types::*;

module mp3
(
    input clk,

    /* Memory signals */
    input mem_resp,
    input lc3b_word mem_rdata,
    output mem_read,
    output mem_write,
    output lc3b_mem_wmask mem_byte_enable,
    output lc3b_word mem_address,
    output lc3b_word mem_wdata
);

lc3b_word de_ex_npc;
lc3b_control_word de_ex_cw;
lc3b_word de_ex_ir;
lc3b_word de_ex_sr1;
lc3b_word de_ex_sr2;
lc3b_nzp de_ex_cc;
lc3b_reg de_ex_dr;

lc3b_word de_ex_npc_out;
lc3b_control_word de_ex_cw_out;
lc3b_word de_ex_ir_out;
lc3b_word de_ex_sr1_out;
lc3b_word de_ex_sr2_out;
lc3b_nzp de_ex_cc_out;
lc3b_reg de_ex_dr_out;


decode decode_int
(
	.clk,
	
	.npc(de_ex_npc),
	.cw(de_ex_cw),
	.ir(de_ex_ir),
	.sr1(de_ex_sr1),
	.sr2(de_ex_sr2),
	.cc(de_ex_cc),
	.dr(de_ex_dr),
	.valid()
);

//decode/execute registers
register de_ex_npc_reg(.clk, .load(1'b1), .in(de_ex_npc), .out(de_ex_npc_out));
register de_ex_cw_reg(.clk, .load(1'b1), .in(de_ex_cw), .out(de_ex_cw_out));
register de_ex_ir_reg(.clk, .load(1'b1), .in(de_ex_ir), .out(de_ex_ir_out));
register de_ex_sr1_reg(.clk, .load(1'b1), .in(de_ex_sr1), .out(de_ex_sr1_out));
register de_ex_sr2_reg(.clk, .load(1'b1), .in(de_ex_sr2), .out(de_ex_sr2_out));
register de_ex_cc_reg(.clk, .load(1'b1), .in(de_ex_cc), .out(de_ex_cc_out));
register de_ex_dr_reg(.clk, .load(1'b1), .in(de_ex_dr), .out(de_ex_dr_out));


execute execute_int
(
	.clk,

	.new_pc_in(de_ex_npc_out),
	.cw_in(de_ex_cw_out),
	.sr1(de_ex_sr1_out),
	.sr2(de_ex_sr2_out),
	.cc_in(de_ex_cc_out),
	.dr_in(de_ex_dr_out),
	.valid_in(),
);

endmodule : mp3