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

//non-register signals
logic [1:0] pc_mux_sel; //needs to come from mem
lc3b_nzp gencc_out;
lc3b_word trap_pc;
lc3b_word target_pc;
lc3b_word reg_data;
lc3b_reg dest_reg;
lc3b_word pc_out;
lc3b_word new_mem_address;
logic new_mem_write;
logic new_mem_read;
logic load_regs;
logic ld_reg_store;
logic ld_cc_store;

//fetch/decode signals
lc3b_word f_de_npc;
lc3b_word f_de_ir;

lc3b_word f_de_npc_out;
lc3b_word f_de_ir_out;

//decode/execute signals
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

//execute/memory signals
lc3b_word ex_mem_address;
lc3b_control_word ex_mem_cw;
lc3b_word ex_mem_npc;
lc3b_nzp ex_mem_cc;
lc3b_word ex_mem_result;
lc3b_word ex_mem_ir;
lc3b_reg ex_mem_dr;

lc3b_word ex_mem_address_out;
lc3b_control_word ex_mem_cw_out;
lc3b_word ex_mem_npc_out;
lc3b_nzp ex_mem_cc_out;
lc3b_word ex_mem_result_out;
lc3b_word ex_mem_ir_out;
lc3b_reg ex_mem_dr_out;

//memory/write_back signals
lc3b_word mem_wb_address;
lc3b_word mem_wb_data;
lc3b_control_word mem_wb_cw;
lc3b_word mem_wb_npc;
lc3b_word mem_wb_result;
lc3b_word mem_wb_ir;
lc3b_reg mem_wb_dr;

lc3b_word mem_wb_address_out;
lc3b_word mem_wb_data_out;
lc3b_control_word mem_wb_cw_out;
lc3b_word mem_wb_npc_out;
lc3b_word mem_wb_result_out;
lc3b_word mem_wb_ir_out;
lc3b_reg mem_wb_dr_out;

assign mem_byte_enable = 2'b11;

//icache signals
lc3b_word icache_rdata;
logic icache_resp;
lc3b_word inst_address;

//stall signals
logic dep_stall;
logic decode_br_stall;
logic execute_br_stall;
logic mem_stall;
logic mem_br_stall;

arbiter arbiter
(
    .clk,
	
	.mem_read_in(new_mem_read),
	.mem_write_in(new_mem_write),
	
	.mem_address_fetch(pc_out),
	.mem_address_mem(new_mem_address),
	
	.ld_regs(load_regs),
	.mem_address,
	.mem_read,
	.mem_write
);


fetch fetch_int
(
    .clk,
    .pc_mux_sel(pc_mux_sel),
    .trap_pc(trap_pc),
    .target_pc(ex_mem_address_out),

    .new_pc(f_de_npc),
    .ir(f_de_ir),
    .valid(),
    
    .icache_rdata,
	 .icache_resp,
	
	 .inst_address(pc_out)
);

//fetch/decode registers
register f_de_npc_reg(.clk, .load(load_regs), .in(f_de_npc), .out(f_de_npc_out));
register f_de_ir_reg(.clk, .load(load_regs), .in(f_de_ir), .out(f_de_ir_out));

decode decode_int
(
	.clk,

   .npc_in(f_de_npc_out),
   .ir_in(f_de_ir_out),
   .valid_in(),
	.ld_reg_store,
	.ld_cc_store,
   .reg_data,
   .cc_data(gencc_out),
   .dest_reg,
	
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
register de_ex_npc_reg(.clk, .load(load_regs), .in(de_ex_npc), .out(de_ex_npc_out));
register #(.width(21)) de_ex_cw_reg(.clk, .load(load_regs), .in(de_ex_cw), .out(de_ex_cw_out));
register de_ex_ir_reg(.clk, .load(load_regs), .in(de_ex_ir), .out(de_ex_ir_out));
register de_ex_sr1_reg(.clk, .load(load_regs), .in(de_ex_sr1), .out(de_ex_sr1_out));
register de_ex_sr2_reg(.clk, .load(load_regs), .in(de_ex_sr2), .out(de_ex_sr2_out));
register #(.width(3)) de_ex_cc_reg(.clk, .load(load_regs), .in(de_ex_cc), .out(de_ex_cc_out));
register #(.width(3)) de_ex_dr_reg(.clk, .load(load_regs), .in(de_ex_dr), .out(de_ex_dr_out));


execute execute_int
(
	.clk,

	.npc_in(de_ex_npc_out),
	.cw_in(de_ex_cw_out),
	.ir_in(de_ex_ir_out),
	.sr1(de_ex_sr1_out),
	.sr2(de_ex_sr2_out),
	.cc_in(de_ex_cc_out),
	.dr_in(de_ex_dr_out),
	.valid_in(),

    .address(ex_mem_address),
    .cw(ex_mem_cw),
    .npc(ex_mem_npc),
    .cc(ex_mem_cc),
    .result(ex_mem_result),
    .ir(ex_mem_ir),
    .dr(ex_mem_dr),
    .valid()
);

//execute/memory registers
register ex_mem_address_reg(.clk, .load(load_regs), .in(ex_mem_address), .out(ex_mem_address_out));
register #(.width(21)) ex_mem_cw_reg(.clk, .load(load_regs), .in(ex_mem_cw), .out(ex_mem_cw_out));
register ex_mem_npc_reg(.clk, .load(load_regs), .in(ex_mem_npc), .out(ex_mem_npc_out));
register #(.width(3)) ex_mem_cc_reg(.clk, .load(load_regs), .in(ex_mem_cc), .out(ex_mem_cc_out));
register ex_mem_result_reg(.clk, .load(load_regs), .in(ex_mem_result), .out(ex_mem_result_out));
register ex_mem_ir_reg(.clk, .load(load_regs), .in(ex_mem_ir), .out(ex_mem_ir_out));
register #(.width(3)) ex_mem_dr_reg(.clk, .load(load_regs), .in(ex_mem_dr), .out(ex_mem_dr_out));

mem mem_int
(
    .clk,
    
    .address_in(ex_mem_address_out),
    .cw_in(ex_mem_cw_out),
    .new_pc_in(ex_mem_npc_out),
    .cc_in(ex_mem_cc_out),
    .result_in(ex_mem_result_out),
    .ir_in(ex_mem_ir_out),
    .dr_in(ex_mem_dr_out),
    .valid_in(),
    
    .mem_rdata,
    .mem_resp,
    
    .mem_address(new_mem_address),
    .mem_read(new_mem_read),
    .mem_write(new_mem_write),
    .mem_wdata,
    
	 .mem_pc_mux(pc_mux_sel),
    
    .address(mem_wb_address),
    .data(mem_wb_data),
    .cw(mem_wb_cw),
    .new_pc(mem_wb_npc),
    .result(mem_wb_result),
    .ir(mem_wb_ir),
    .dr(mem_wb_dr)
);

//mem/write_back register
register mem_wb_address_reg(.clk, .load(load_regs), .in(mem_wb_address), .out(mem_wb_address_out));
register mem_wb_data_reg(.clk, .load(load_regs), .in(mem_wb_data), .out(mem_wb_data_out));
register #(.width(21)) mem_wb_cw_reg(.clk, .load(load_regs), .in(mem_wb_cw), .out(mem_wb_cw_out));
register mem_wb_npc_reg(.clk, .load(load_regs), .in(mem_wb_npc), .out(mem_wb_npc_out));
register mem_wb_result_reg(.clk, .load(load_regs), .in(mem_wb_result), .out(mem_wb_result_out));
register mem_wb_ir_reg(.clk, .load(load_regs), .in(mem_wb_ir), .out(mem_wb_ir_out));
register #(.width(3)) mem_wb_dr_reg(.clk, .load(load_regs), .in(mem_wb_dr), .out(mem_wb_dr_out));

write_back write_back_int
(
    .clk,
    
    .mem_address(mem_wb_address_out),
    .data(mem_wb_data_out),
    .cw(mem_wb_cw_out),
    .npc(mem_wb_npc_out),
    .result(mem_wb_result_out),
    .dr(mem_wb_dr_out),
    .ir(mem_wb_ir_out),
    .valid(),
    
    .gencc_out,
    .reg_data,
    .dest_reg,
    .ld_reg_store,
    .ld_cc_store
);

endmodule : mp3
