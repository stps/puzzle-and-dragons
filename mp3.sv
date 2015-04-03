import lc3b_types::*;

module mp3
(
    input clk,

    /* Memory signals */
	 input pmem_resp,
	 input lc3b_c_block pmem_rdata,
	 
	 output pmem_read,
	 output pmem_write,
	 
	 output lc3b_word pmem_address,
	 output lc3b_c_block pmem_wdata
);

//non-register signals
logic [1:0] pc_mux_sel; //needs to come from mem
lc3b_nzp gencc_out;
lc3b_word trap_pc;
lc3b_word target_pc;
lc3b_word reg_data;
lc3b_reg dest_reg;
lc3b_word pc_out;

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

//icache signals
lc3b_word icache_address;
logic icache_read;
lc3b_word icache_rdata;
logic icache_resp;

lc3b_word icache_pmem_address;
lc3b_c_block icache_pmem_rdata;
logic icache_pmem_read;
logic icache_pmem_resp;

//dcache signals
lc3b_word dcache_address;
logic dcache_resp;
logic dcache_read;
lc3b_word dcache_rdata;
logic dcache_write;
lc3b_word dcache_wdata;

lc3b_word dcache_pmem_address;
logic dcache_pmem_resp
logic dcache_pmem_read;
lc3b_c_block dcache_pmem_rdata;
logic dcache_pmem_write;
lc3b_c_block dcache_pmem_wdata;
;

/* T
	E
	M
	P
	O
	R
	A
	R
	Y
	*/
assign mem_byte_enable = 2'b11;

//stall signals
logic dep_stall;
logic decode_br_stall;
logic execute_br_stall;
logic mem_stall;
logic mem_br_stall;

cache i_cache
(
	.clk,
	
	.mem_address(icache_address),
	.mem_byte_enable,
	.mem_resp(icache_resp),

	.mem_write(1'b0),
	.mem_wdata(),
	
	.mem_read(),
	.mem_rdata(icache_rdata),
	
	.pmem_address(icache_pmem_address),
	.pmem_resp(icache_pmem_resp),

	.pmem_read(icache_pmem_read),
	.pmem_rdata(icache_pmem_rdata),
	
	.pmem_write(),
	.pmem_wdata()
);

cache d_cache
(
	.clk,
	
	.mem_address(dcache_address),
	.mem_byte_enable,
	.mem_resp(dcache_resp),

	.mem_write(dcache_write),
	.mem_wdata(dcache_wdata),
	
	.mem_read(dcache_read),
	.mem_rdata(dcache_rdata),
	
	.pmem_address(dcache_pmem_address),
	.pmem_resp(dcache_pmem_resp),

	.pmem_read(dcache_pmem_read),
	.pmem_rdata(dcache_pmem_rdata),
	
	.pmem_write(dcache_pmem_write),
	.pmem_wdata(dcache_pmem_wdata)
);

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
	 .icache_address(pc_out),
	 
	 .icache_read
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
register #(.width($bits(lc3b_control_word))) de_ex_cw_reg(.clk, .load(load_regs), .in(de_ex_cw), .out(de_ex_cw_out));
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
register #(.width($bits(lc3b_control_word))) ex_mem_cw_reg(.clk, .load(load_regs), .in(ex_mem_cw), .out(ex_mem_cw_out));
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
    
    .mem_rdata(dcache_rdata),
    .mem_resp(dcache_resp),
    
    .mem_address(dcache_address),
    .mem_read(dcache_read),
    .mem_write(dcache_write),
    .mem_wdata(dcache_wdata),
    
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
register #(.width($bits(lc3b_control_word))) mem_wb_cw_reg(.clk, .load(load_regs), .in(mem_wb_cw), .out(mem_wb_cw_out));
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
