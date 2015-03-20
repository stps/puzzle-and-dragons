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

logic [1:0] pc_mux_sel; //needs to come from mem
lc3b_word trap_pc;
lc3b_word target_pc;
lc3b_word f_de_npc;
lc3b_word f_de_ir;

lc3b_word f_de_npc_out;
lc3b_word f_de_ir_out;

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

lc3b_word reg_data;

fetch fetch_int
(
    .clk,
    .pc_mux_sel(pc_mux_sel),
    .trap_pc(trap_pc),
    .target_pc(target_pc),

    .new_pc(f_de_npc),
    .ir(f_de_ir),
    .valid(),
    .stall()
);

//fetch/decode registers
register f_de_npc_reg(.clk, .load(1'b1), .in(f_de_npc), .out(f_de_npc_out));
register f_de_ir_reg(.clk, .load(1'b1), .in(f_de_ir), .out(f_de_ir_out));

decode decode_int
(
	.clk,

    .npc_in(f_de_npc_out),
    .ir_in(f_de_ir_out),
    .valid_in(),
    .reg_data(reg_data),
    .cc_data(),
    .dest_reg(),
	
	.npc(de_ex_npc),
	.cw(de_ex_cw),
	.ir(de_ex_ir),
	.sr1(de_ex_sr1),
	.sr2(de_ex_sr2),
	.cc_out(de_ex_cc),
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

    .mem_address(),
    .cw(),
    .new_pc(),
    .cc(),
    .alu_out(),
    .ir(),
    .dr(),
    .valid()
);

//execute/mem registers

mem mem_int
(
    .clk,
    
    .address_in(),
    .cw_in(),
    .new_pc_in(),
    .cc_in(),
    .result_in(),
    .ir_in(),
    .dr_in(),
    .valid_in(),
    
    .mem_rdata,
    .mem_resp,
    
    .mem_address,
    .mem_read,
    .mem_write,
    .mem_wdata,
    
    .address(),
    .data(),
    .cw(),
    .new_pc(),
    .result(),
    .ir(),
    .dr(),
    .valid(),
    .stall()
);

//mem/write_back registers

write_back write_back_int
(
    .clk,
    
    .mem_address(),
    .data(),
    .cw(),
    .new_pc(),
    .alu_out(),
    .ir(),
    .valid(),
    
    .gencc_out(),
    .reg_data(reg_data)
);

endmodule : mp3