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
lc3b_mem_wmask mem_byte_enable;

logic load_regs;

//fetch/decode signals
lc3b_word f_de_npc;
lc3b_word f_de_ir;
logic f_de_valid;

lc3b_word f_de_npc_out;
lc3b_word f_de_ir_out;
logic f_de_valid_out;

//decode/execute signals
lc3b_word de_ex_npc;
lc3b_control_word de_ex_cw;
lc3b_word de_ex_ir;
lc3b_word de_ex_sr1;
lc3b_word de_ex_sr2;
lc3b_nzp de_ex_cc;
lc3b_reg de_ex_dr;
logic de_ex_valid;

lc3b_word de_ex_npc_out;
lc3b_control_word de_ex_cw_out;
lc3b_word de_ex_ir_out;
lc3b_word de_ex_sr1_out;
lc3b_word de_ex_sr2_out;
lc3b_nzp de_ex_cc_out;
lc3b_reg de_ex_dr_out;
logic de_ex_valid_out;

//execute/memory signals
lc3b_word ex_mem_address;
lc3b_control_word ex_mem_cw;
lc3b_word ex_mem_npc;
lc3b_nzp ex_mem_cc;
lc3b_word ex_mem_result;
lc3b_word ex_mem_ir;
lc3b_reg ex_mem_dr;
logic ex_mem_valid;

lc3b_word ex_mem_address_out;
lc3b_control_word ex_mem_cw_out;
lc3b_word ex_mem_npc_out;
lc3b_nzp ex_mem_cc_out;
lc3b_word ex_mem_result_out;
lc3b_word ex_mem_ir_out;
lc3b_reg ex_mem_dr_out;
logic ex_mem_valid_out;

//memory/write_back signals
lc3b_word mem_wb_address;
lc3b_word mem_wb_data;
lc3b_control_word mem_wb_cw;
lc3b_word mem_wb_npc;
lc3b_word mem_wb_result;
lc3b_word mem_wb_ir;
lc3b_reg mem_wb_dr;
logic mem_wb_valid;

lc3b_word mem_wb_address_out;
lc3b_word mem_wb_data_out;
lc3b_control_word mem_wb_cw_out;
lc3b_word mem_wb_npc_out;
lc3b_word mem_wb_result_out;
lc3b_word mem_wb_ir_out;
lc3b_reg mem_wb_dr_out;
logic mem_wb_valid_out;

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
logic dcache_resp;
logic dcache_read;
lc3b_word dcache_rdata;
logic dcache_write;
lc3b_word dcache_wdata;

lc3b_word dcache_pmem_address;
logic dcache_pmem_resp;
logic dcache_pmem_read;
lc3b_c_block dcache_pmem_rdata;
logic dcache_pmem_write;
lc3b_c_block dcache_pmem_wdata;

//stall signals
logic dep_stall;
logic decode_br_stall;
logic execute_br_stall;
logic execute_indirect_stall;
logic mem_stall;
logic mem_br_stall;
logic icache_stall_int;

//latch load signals
logic load_de;
logic load_ex;
logic load_mem;
logic load_wb;

//latch valid signals
logic valid_de;
logic valid_ex;
logic valid_mem;

//dep stuff
logic ex_ld_cc;
logic mem_ld_cc;
logic wb_ld_cc;
	
lc3b_reg ex_drid;
lc3b_reg mem_drid;
lc3b_reg wb_drid;
	
logic ex_ld_reg;
logic mem_ld_reg;
logic wb_ld_reg;

assign mem_drid = ex_mem_dr_out;
assign ex_drid = de_ex_dr_out;
assign wb_drid = mem_wb_dr_out;

assign trap_pc = mem_wb_data;

cache i_cache
(
	.clk,
	
	.mem_address(icache_address),
	.mem_byte_enable,
	.mem_resp(icache_resp),

	.mem_write(1'b0),
	.mem_wdata(),
	
	.mem_read(icache_read),
	.mem_rdata(icache_rdata),
	
	.pmem_address(icache_pmem_address),
	.pmem_resp(icache_pmem_resp),

	.pmem_read(icache_pmem_read),
	.pmem_rdata,
	
	.pmem_write(),
	.pmem_wdata()
);

cache d_cache
(
	.clk,
	
	.mem_address(mem_wb_address),
	.mem_byte_enable,
	.mem_resp(dcache_resp),

	.mem_write(dcache_write),
	.mem_wdata(dcache_wdata),
	
	.mem_read(dcache_read),
	.mem_rdata(dcache_rdata),
	
	.pmem_address(dcache_pmem_address),
	.pmem_resp(dcache_pmem_resp),

	.pmem_read(dcache_pmem_read),
	.pmem_rdata,
	
	.pmem_write(dcache_pmem_write),
	.pmem_wdata
);

arbiter arbiter
(
	.clk,
	
	.icache_pmem_read,
	.icache_pmem_address,
	
	.dcache_pmem_read,
	.dcache_pmem_write,
	.dcache_pmem_address,
	
	.pmem_resp,
	
	.ld_regs(load_regs),
	
	.icache_pmem_resp,
	.dcache_pmem_resp,
	
	.pmem_address,
	.pmem_read,
	.pmem_write
);


fetch fetch_int
(
    .clk,
    .pc_mux_sel,
    .trap_pc,
    .target_pc(ex_mem_address_out),
	 
	 .dep_stall,
	 .decode_br_stall,
	 .execute_br_stall,
	 .execute_indirect_stall,
	 .mem_stall,
	 .mem_br_stall,
    
    .icache_rdata,
	 .icache_resp,
	 .icache_address,
	 .icache_read,
	 .icache_stall_int,
	 
	 .mem_valid_in(ex_mem_valid_out),
	 
	 .new_pc(f_de_npc),
    .ir(f_de_ir),
	 .valid(valid_de),
	 .load_de
);

//fetch/decode registers
register f_de_npc_reg(.clk, .load(load_de && load_regs), .in(f_de_npc), .out(f_de_npc_out));
register f_de_ir_reg(.clk, .load(load_de && load_regs), .in(f_de_ir), .out(f_de_ir_out));
register #(.width(1)) f_de_valid_reg(.clk, .load(load_de && load_regs), .in(valid_de), .out(f_de_valid_out));

decode decode_int
(
	.clk,

	.npc_in(f_de_npc_out),
	.ir_in(f_de_ir_out),
	.valid_in(),

	.reg_data,
	.cc_data(gencc_out),
	.dest_reg,
	
	.ex_ld_cc,
	.mem_ld_cc,
	.wb_ld_cc,
	
	.ex_drid,
	.mem_drid,
	.wb_drid,
	
	.ex_ld_reg,	 
	.mem_ld_reg,
	.wb_ld_reg,
	
	.npc(de_ex_npc),
	.cw(de_ex_cw),
	.ir(de_ex_ir),
	.sr1(de_ex_sr1),
	.sr2(de_ex_sr2),
	.cc_out(de_ex_cc),
	.dr(de_ex_dr),
	.valid(valid_ex),
	.load_ex,
	
	.icache_stall_int,
	.dep_stall,
	.decode_br_stall,
	.execute_br_stall,
	.execute_indirect_stall,
	.mem_stall,
	.mem_br_stall
);

//decode/execute registers
register de_ex_npc_reg(.clk, .load(load_ex && load_regs), .in(de_ex_npc), .out(de_ex_npc_out));
register #(.width($bits(lc3b_control_word))) de_ex_cw_reg(.clk, .load(load_ex && load_regs), .in(de_ex_cw), .out(de_ex_cw_out));
register de_ex_ir_reg(.clk, .load(load_ex && load_regs), .in(de_ex_ir), .out(de_ex_ir_out));
register de_ex_sr1_reg(.clk, .load(load_ex && load_regs), .in(de_ex_sr1), .out(de_ex_sr1_out));
register de_ex_sr2_reg(.clk, .load(load_ex && load_regs), .in(de_ex_sr2), .out(de_ex_sr2_out));
register #(.width(3)) de_ex_cc_reg(.clk, .load(load_ex && load_regs), .in(de_ex_cc), .out(de_ex_cc_out));
register #(.width(3)) de_ex_dr_reg(.clk, .load(load_ex && load_regs), .in(de_ex_dr), .out(de_ex_dr_out));
register #(.width(3)) de_ex_rs_reg(.clk, .load(load_ex && load_regs), .in(de_ex_rs), .out(de_ex_rs_out));
register #(.width(3)) de_ex_rt_reg(.clk, .load(load_ex && load_regs), .in(de_ex_rt), .out(de_ex_rt_out));
register #(.width(1)) de_ex_valid_reg(.clk, .load(load_ex && load_regs), .in(valid_ex), .out(de_ex_valid_out));

forwarding_unit forwarding_unit
(
    .ex_mem_dr_out,
    .mem_wb_dr_out,
    .de_ex_rs_out,
    .de_ex_rt_out,
    
    .forwardA_mux_sel,
    .forwardB_mux_sel
);

mux4 forwardA_mux
(
	.sel(forwardA_mux_sel),
	.a(de_ex_sr1_out),
	.b(reg_data),
	.c(ex_mem_result_out),
	.out(forwardA_mux_out)
);

mux4 forwardB_mux
(
	.sel(forwardB_mux_sel),
	.a(de_ex_sr2_out),
	.b(reg_data),
	.c(ex_mem_result_out),
	.out(forwardB_mux_out)
);

execute execute_int
(
	.clk,

	.npc_in(de_ex_npc_out),
	.cw_in(de_ex_cw_out),
	.ir_in(de_ex_ir_out),
	.sr1(forwardA_mux_out),
	.sr2(forwardB_mux_out),
	.cc_in(de_ex_cc_out),
	.dr_in(de_ex_dr_out),
	.valid_in(de_ex_valid_out),

	.icache_stall_int,
	.dep_stall,
	.decode_br_stall,
	.mem_stall,
	.mem_br_stall,
	
	.next_opcode(ex_mem_cw_out.opcode),
	
	.address(ex_mem_address),
	.cw(ex_mem_cw),
	.npc(ex_mem_npc),
	.cc(ex_mem_cc),
	.result(ex_mem_result),
	.ir(ex_mem_ir),
	.dr(ex_mem_dr),
	.valid(ex_mem_valid),
	.load_mem,
	
	.ex_load_cc(ex_ld_cc),
   .ex_load_regfile(ex_ld_reg),
	.execute_br_stall,
	.execute_indirect_stall
);

//execute/memory registers
register ex_mem_address_reg(.clk, .load(load_mem && load_regs), .in(ex_mem_address), .out(ex_mem_address_out));
register #(.width($bits(lc3b_control_word))) ex_mem_cw_reg(.clk, .load(load_mem && load_regs), .in(ex_mem_cw), .out(ex_mem_cw_out));
register ex_mem_npc_reg(.clk, .load(load_mem && load_regs), .in(ex_mem_npc), .out(ex_mem_npc_out));
register #(.width(3)) ex_mem_cc_reg(.clk, .load(load_mem && load_regs), .in(ex_mem_cc), .out(ex_mem_cc_out));
register ex_mem_result_reg(.clk, .load(load_mem && load_regs), .in(ex_mem_result), .out(ex_mem_result_out));
register ex_mem_ir_reg(.clk, .load(load_mem && load_regs), .in(ex_mem_ir), .out(ex_mem_ir_out));
register #(.width(3)) ex_mem_dr_reg(.clk, .load(load_mem && load_regs), .in(ex_mem_dr), .out(ex_mem_dr_out));
register #(.width(1)) ex_mem_valid_reg(.clk, .load(load_mem && load_regs), .in(ex_mem_valid), .out(ex_mem_valid_out));

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
	.valid_in(ex_mem_valid_out),
	
	.mem_rdata(dcache_rdata),
	.dcache_resp,
	.indirect_data_in(mem_wb_data_out),
	.indirect_reg_in(mem_wb_dr_out),
	.indirect_result_in(mem_wb_result_out),
	
	.mem_address(mem_wb_address),
	.mem_read(dcache_read),
	.mem_write(dcache_write),
	.mem_wdata(dcache_wdata),
	
	.mem_pc_mux(pc_mux_sel),
	
	.data(mem_wb_data),
	.cw(mem_wb_cw),
	.new_pc(mem_wb_npc),
	.result(mem_wb_result),
	.ir(mem_wb_ir),
	.dr(mem_wb_dr),

	.valid(mem_wb_valid),
	
	.icache_stall_int,
	.mem_stall,
	.mem_br_stall,
	.load_wb,
	
	.mem_load_cc(mem_ld_cc),
	.mem_load_regfile(mem_ld_reg),

	.mem_byte_enable
);

//mem/write_back register
register mem_wb_address_reg(.clk, .load(load_wb && load_regs), .in(mem_wb_address), .out(mem_wb_address_out));
register mem_wb_data_reg(.clk, .load(load_wb && load_regs), .in(mem_wb_data), .out(mem_wb_data_out));
register #(.width($bits(lc3b_control_word))) mem_wb_cw_reg(.clk, .load(load_wb && load_regs), .in(mem_wb_cw), .out(mem_wb_cw_out));
register mem_wb_npc_reg(.clk, .load(load_wb && load_regs), .in(mem_wb_npc), .out(mem_wb_npc_out));
register mem_wb_result_reg(.clk, .load(load_wb && load_regs), .in(mem_wb_result), .out(mem_wb_result_out));
register mem_wb_ir_reg(.clk, .load(load_wb && load_regs), .in(mem_wb_ir), .out(mem_wb_ir_out));
register #(.width(3)) mem_wb_dr_reg(.clk, .load(load_wb && load_regs), .in(mem_wb_dr), .out(mem_wb_dr_out));
register #(.width(1)) mem_wb_valid_reg(.clk, .load(load_wb && load_regs), .in(mem_wb_valid), .out(mem_wb_valid_out));

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
    .valid(mem_wb_valid_out),
    
    .gencc_out,
    .reg_data,
    .dest_reg,
    .wb_ld_reg,
    .wb_ld_cc
);

endmodule : mp3
