import lc3b_types::*;

module mp3
(
    input clk,

    /* Memory signals */
	 input pmem_resp,
	 input lc3b_l2_block pmem_rdata,
	 
	 output pmem_read,
	 output pmem_write,
	 
	 output lc3b_word pmem_address,
	 output lc3b_l2_block pmem_wdata
);

//non-register signals
logic [1:0] pc_mux_sel; //needs to come from mem
logic [1:0] mem_pc_mux;
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
lc3b_reg de_ex_rs;
lc3b_reg de_ex_rt;
logic de_ex_valid;

lc3b_word de_ex_npc_out;
lc3b_control_word de_ex_cw_out;
lc3b_word de_ex_ir_out;
lc3b_word de_ex_sr1_out;
lc3b_word de_ex_sr2_out;
lc3b_nzp de_ex_cc_out;
lc3b_reg de_ex_dr_out;
lc3b_reg de_ex_rs_out;
lc3b_reg de_ex_rt_out;
logic de_ex_valid_out;

//execute/memory signals
lc3b_word ex_mem_address;
lc3b_control_word ex_mem_cw;
lc3b_word ex_mem_npc;
lc3b_nzp ex_mem_cc;
lc3b_word ex_mem_result;
lc3b_word ex_mem_ir;
lc3b_reg ex_mem_dr;
lc3b_reg ex_mem_rs;
lc3b_reg ex_mem_rt;
logic ex_mem_valid;

lc3b_word ex_mem_address_out;
lc3b_control_word ex_mem_cw_out;
lc3b_word ex_mem_npc_out;
lc3b_nzp ex_mem_cc_out;
lc3b_word ex_mem_result_out;
lc3b_word ex_mem_ir_out;
lc3b_reg ex_mem_dr_out;
lc3b_reg ex_mem_rs_out;
lc3b_reg ex_mem_rt_out;
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

//arbiter signals
lc3b_word l2_address;
logic l2_read;
logic l2_write;
logic l2_resp;
lc3b_c_block l2_rdata;
lc3b_c_block l2_wdata;

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

//hazard signals
logic mem_ex_hazard;
logic wb_ex_hazard;
logic wb_mem_hazard;

//forwarding unit signals
logic [1:0] forwardA_mux_sel;
logic [1:0] forwardB_mux_sel;
lc3b_word forwardA_mux_out;
lc3b_word forwardB_mux_out;

//leapfrogging signals
logic leapfrog_stall;
logic leapfrog_load;
logic lost_leapfrog;
lc3b_word mem_wb_address_in;
lc3b_control_word mem_wb_cw_in;
lc3b_word mem_wb_npc_in;
lc3b_word mem_wb_result_in;
lc3b_word mem_wb_ir_in;
lc3b_reg mem_wb_dr_in;
logic mem_wb_valid_in;

lc3b_word branch_address;
logic [1:0] leap_br_pcmux_sel;
logic [1:0] leap_pc_mux;

//assign leapfrog_load = 1'b0;

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
	.pmem_rdata(l2_rdata),
	
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
	.pmem_rdata(l2_rdata),
	
	.pmem_write(dcache_pmem_write),
	.pmem_wdata(dcache_pmem_wdata)
);

arbiter arbiter
(
	.clk,
	
	.icache_pmem_read,
	.icache_pmem_address,
	
	.dcache_pmem_read,
	.dcache_pmem_write,
	.dcache_pmem_address,
	.dcache_pmem_wdata,
	
	.l2_resp,
	
	.ld_regs(load_regs),
	
	.icache_pmem_resp,
	.dcache_pmem_resp,
	
	.l2_address,
	.l2_wdata, 
	
	.l2_read,
	.l2_write
);

l2_cache l2_cache
(
	.clk,

	.mem_address(l2_address),
	.mem_wdata(l2_wdata),
	.mem_read(l2_read),
	.mem_write(l2_write),
	 
	.mem_rdata(l2_rdata),
	.mem_resp(l2_resp),
	 
	.pmem_rdata,
	.pmem_resp,
	 
	.pmem_address,
	.pmem_read,
	.pmem_write,
	.pmem_wdata
);


fetch fetch_int
(
	.clk,
	.pc_mux_sel,
	.trap_pc,
	.target_pc(branch_address),
	.load_regs,

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
	
	.leapfrog_load,
	.leapfrog_stall,
	.lost_leapfrog,

	.new_pc(f_de_npc),
	.ir(f_de_ir),
	.valid(valid_de),
	.load_de
);

//fetch/decode registers
register f_de_npc_reg(.clk, .load(load_de && load_regs || load_de && leapfrog_load), .in(f_de_npc), .out(f_de_npc_out));
register f_de_ir_reg(.clk, .load(load_de && load_regs || load_de && leapfrog_load), .in(f_de_ir), .out(f_de_ir_out));
register #(.width(1)) f_de_valid_reg(.clk, .load(load_de && load_regs || load_de && leapfrog_load), .in(valid_de), .out(f_de_valid_out));

decode decode_int
(
	.clk,

	.npc_in(f_de_npc_out),
	.ir_in(f_de_ir_out),
	.valid_in(f_de_valid_out),

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
	
	.leapfrog_load,
	.leapfrog_stall,
	.lost_leapfrog,
	
	.ex_valid(de_ex_valid_out),
	.mem_valid(ex_mem_valid_out),
	.wb_valid(mem_wb_valid_out),
	
	.npc(de_ex_npc),
	.cw(de_ex_cw),
	.ir(de_ex_ir),
	.sr1(de_ex_sr1),
	.sr2(de_ex_sr2),
	.cc_out(de_ex_cc),
	.dr(de_ex_dr),
	.sr1_reg(de_ex_rs),
	.sr2_reg(de_ex_rt),
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
register de_ex_npc_reg(.clk, .load(load_ex && load_regs || load_ex && leapfrog_load), .in(de_ex_npc), .out(de_ex_npc_out));
register #(.width($bits(lc3b_control_word))) de_ex_cw_reg(.clk, .load(load_ex && load_regs || load_ex && leapfrog_load), .in(de_ex_cw), .out(de_ex_cw_out));
register de_ex_ir_reg(.clk, .load(load_ex && load_regs || load_ex && leapfrog_load), .in(de_ex_ir), .out(de_ex_ir_out));
register de_ex_sr1_reg(.clk, .load(load_ex && load_regs || load_ex && leapfrog_load), .in(de_ex_sr1), .out(de_ex_sr1_out));
register de_ex_sr2_reg(.clk, .load(load_ex && load_regs || load_ex && leapfrog_load), .in(de_ex_sr2), .out(de_ex_sr2_out));
register #(.width(3)) de_ex_cc_reg(.clk, .load(load_ex && load_regs || load_ex && leapfrog_load), .in(de_ex_cc), .out(de_ex_cc_out));
register #(.width(3)) de_ex_dr_reg(.clk, .load(load_ex && load_regs || load_ex && leapfrog_load), .in(de_ex_dr), .out(de_ex_dr_out));
register #(.width(3)) de_ex_rs_reg(.clk, .load(load_ex && load_regs || load_ex && leapfrog_load), .in(de_ex_rs), .out(de_ex_rs_out));
register #(.width(3)) de_ex_rt_reg(.clk, .load(load_ex && load_regs || load_ex && leapfrog_load), .in(de_ex_rt), .out(de_ex_rt_out));
register #(.width(1)) de_ex_valid_reg(.clk, .load(load_ex && load_regs || load_ex && leapfrog_load), .in(valid_ex), .out(de_ex_valid_out));


hazard_detection hazard_detection
(
	.de_ex_rs_out,
	.de_ex_rt_out,
	.mem_wb_dr_out,
	.ex_mem_dr_out,
	
	.mem_ex_hazard,
	.wb_ex_hazard,
	.wb_mem_hazard

);

forwarding_unit forwarding_unit
(
    //.ex_mem_load_regfile(ex_mem_cw_out.load_regfile),
    //.mem_wb_load_regfile(mem_wb_cw_out.load_regfile),
	 .ex_mem_load_regfile(load_mem && load_regs),
    .mem_wb_load_regfile(load_wb && load_regs),
    .ex_mem_dr_out,
    .mem_wb_dr_out,
    .de_ex_rs_out,
    .de_ex_rt_out,
	 
	 .de_ex_valid_out,
	 .ex_mem_valid_out,
	 .mem_wb_valid_out,
    
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
	.sr1_reg_in(de_ex_rs_out),
	.sr2_reg_in(de_ex_rt_out),
	.valid_in(de_ex_valid_out),

	.icache_stall_int,
	.dep_stall,
	.decode_br_stall,
	.mem_stall,
	.mem_br_stall,
	
	//leapfrogging
	.mem_dr(ex_mem_dr_out),
	.leapfrog_load,
	.leapfrog_stall,
	.lost_leapfrog,
	.wb_ld_cc,
	.mem_ld_cc,
	.mem_valid(ex_mem_valid_out),
	
	.next_opcode(ex_mem_cw_out.opcode),
	
	.address(ex_mem_address),
	.cw(ex_mem_cw),
	.npc(ex_mem_npc),
	.cc(ex_mem_cc),
	.result(ex_mem_result),
	.ir(ex_mem_ir),
	.dr(ex_mem_dr),
	.sr1_reg(ex_mem_rs),
	.sr2_reg(ex_mem_rt),
	.valid(ex_mem_valid),
	.load_mem,
	
	.ex_load_cc(ex_ld_cc),
	.ex_load_regfile(ex_ld_reg),
	.execute_br_stall,
	.execute_indirect_stall
	
);

mux2 leap_branch
(
	.sel(leapfrog_load),
	.a(ex_mem_address_out), // regular branch
	.b(ex_mem_address),	// branch that is leapfrogged, jumps in execute
	.out(branch_address)
);

mux2 #(.width(2)) pc_mux_mux
(
	.sel(leapfrog_load),
	.a(mem_pc_mux),
	.b(leap_pc_mux),
	.out(pc_mux_sel)
);

leap_control_logic leap_control_logic
(
	.leapfrog_load,
	.leap_br_pcmux_sel,
	.cw_in(ex_mem_cw),
	.valid_in(ex_mem_valid),
	
	.leap_pc_mux
);


cccomp comp
(
	.a(ex_mem_ir),
	.b(gencc_out),
	.out(leap_br_pcmux_sel)
);

//execute/memory registers
register ex_mem_address_reg(.clk, .load(load_mem && load_regs || load_mem && leapfrog_load), .in(ex_mem_address), .out(ex_mem_address_out));
register #(.width($bits(lc3b_control_word))) ex_mem_cw_reg(.clk, .load(load_mem && load_regs || load_mem && leapfrog_load), .in(ex_mem_cw), .out(ex_mem_cw_out));
register ex_mem_npc_reg(.clk, .load(load_mem && load_regs || load_mem && leapfrog_load), .in(ex_mem_npc), .out(ex_mem_npc_out));
register #(.width(3)) ex_mem_cc_reg(.clk, .load(load_mem && load_regs || load_mem && leapfrog_load), .in(ex_mem_cc), .out(ex_mem_cc_out));
register ex_mem_result_reg(.clk, .load(load_mem && load_regs || load_mem && leapfrog_load), .in(ex_mem_result), .out(ex_mem_result_out));
register ex_mem_ir_reg(.clk, .load(load_mem && load_regs || load_mem && leapfrog_load), .in(ex_mem_ir), .out(ex_mem_ir_out));
register #(.width(3)) ex_mem_dr_reg(.clk, .load(load_mem && load_regs || load_mem && leapfrog_load), .in(ex_mem_dr), .out(ex_mem_dr_out));
register #(.width(3)) ex_mem_rs_reg(.clk, .load(load_mem && load_regs || load_mem && leapfrog_load), .in(ex_mem_rs), .out(ex_mem_rs_out));
register #(.width(3)) ex_mem_rt_reg(.clk, .load(load_mem && load_regs || load_mem && leapfrog_load), .in(ex_mem_rt), .out(ex_mem_rt_out));
register #(.width(1)) ex_mem_valid_reg(.clk, .load(load_mem && load_regs || load_mem && leapfrog_load), .in(ex_mem_valid), .out(ex_mem_valid_out));

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
	
	.mem_pc_mux,
	
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

mux2 address_reg_lf_mux (.sel(leapfrog_load), .a(mem_wb_address), .b (ex_mem_address), .out(mem_wb_address_in));
//dont need data
mux2 #(.width($bits(lc3b_control_word))) cw_reg_lf_mux (.sel(leapfrog_load), .a(mem_wb_cw), .b(ex_mem_cw), .out(mem_wb_cw_in));
mux2 npc_reg_lf_mux (.sel(leapfrog_load), .a(mem_wb_npc), .b(ex_mem_npc), .out(mem_wb_npc_in));
mux2 result_reg_lf_mux (.sel(leapfrog_load), .a(mem_wb_result), .b(ex_mem_result), .out(mem_wb_result_in));
mux2 ir_reg_lf_mux (.sel(leapfrog_load), .a(mem_wb_ir), .b(ex_mem_ir), .out(mem_wb_ir_in));
mux2 #(.width(3)) dr_reg_lf_mux (.sel(leapfrog_load), .a(mem_wb_dr), .b(ex_mem_dr), .out(mem_wb_dr_in));
mux2 #(.width(1)) valid_reg_lf_mux (.sel(leapfrog_load), .a(mem_wb_valid), .b(ex_mem_valid), .out(mem_wb_valid_in));

//mem/write_back register
register mem_wb_address_reg(.clk, .load(load_wb && load_regs || load_wb && leapfrog_load), .in(mem_wb_address_in), .out(mem_wb_address_out));
register mem_wb_data_reg(.clk, .load(load_wb && load_regs || load_wb && leapfrog_load), .in(mem_wb_data), .out(mem_wb_data_out));
register #(.width($bits(lc3b_control_word))) mem_wb_cw_reg(.clk, .load(load_wb && load_regs || load_wb && leapfrog_load), .in(mem_wb_cw_in), .out(mem_wb_cw_out));
register mem_wb_npc_reg(.clk, .load(load_wb && load_regs || load_wb && leapfrog_load), .in(mem_wb_npc_in), .out(mem_wb_npc_out));
register mem_wb_result_reg(.clk, .load(load_wb && load_regs || load_wb && leapfrog_load), .in(mem_wb_result_in), .out(mem_wb_result_out));
register mem_wb_ir_reg(.clk, .load(load_wb && load_regs || load_wb && leapfrog_load), .in(mem_wb_ir_in), .out(mem_wb_ir_out));
register #(.width(3)) mem_wb_dr_reg(.clk, .load(load_wb && load_regs || load_wb && leapfrog_load), .in(mem_wb_dr_in), .out(mem_wb_dr_out));
register #(.width(1)) mem_wb_valid_reg(.clk, .load(load_wb && load_regs || load_wb && leapfrog_load), .in(mem_wb_valid_in), .out(mem_wb_valid_out));


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
