import lc3b_types::*;

module decode
(
	input clk,
	input lc3b_word npc_in,
	input lc3b_word ir_in,
	input valid_in,

	input lc3b_word reg_data,
	input lc3b_nzp cc_data,
	input lc3b_reg dest_reg,
	
	// dep check signals
	input ex_ld_cc,
	input mem_ld_cc,
	input wb_ld_cc,
	
	input lc3b_reg ex_drid,
	input lc3b_reg mem_drid,
	input lc3b_reg wb_drid,
	
	input logic ex_ld_reg,
	input logic mem_ld_reg,
	input logic wb_ld_reg,
	
	input logic ex_valid,
	input logic mem_valid,
	input logic wb_valid,
	
	output lc3b_word npc, 
	output lc3b_control_word cw,
	output lc3b_word ir,
	output lc3b_word sr1,
	output lc3b_word sr2,
	output lc3b_nzp cc_out,
	output lc3b_reg dr,
	output lc3b_reg sr1_reg,
	output lc3b_reg sr2_reg,
	output logic valid,
	output logic load_ex,
	
	output logic dep_stall,
	output logic decode_br_stall,
	
	input execute_br_stall,
	input execute_indirect_stall,
	input mem_stall,
	input mem_br_stall,
	input logic icache_stall_int
);

lc3b_reg regfilemux_out;
lc3b_reg destmux_out;
lc3b_control_word cw_rom;

assign sr1_reg = ir_in[8:6];
assign sr2_reg = regfilemux_out;

always_comb
begin
	npc = npc_in;
	ir = ir_in;
	dr = destmux_out;
end

control_rom control_store
(
    .opcode(lc3b_opcode'(ir_in[15:12])),
    .imm_check(ir_in[5]),
    .jsr_check(ir_in[11]),
    .rshf_check(ir_in[4]),
    .ctrl(cw_rom)
);

nop_check nop_check
(
	.instruction(ir_in),
	.cw_rom,
	.ctrl(cw)
);

regfile regfile_int
(
	.clk,
	.load(wb_ld_reg),
	.in(reg_data),
	.src_a(ir_in[8:6]),
	.src_b(regfilemux_out),
	.dest(dest_reg),
	.reg_a(sr1),
	.reg_b(sr2)
);

mux2 #(.width(3)) regfilemux(.a(ir_in[11:9]), .b(ir_in[2:0]), .out(regfilemux_out), .sel(cw.regfilemux_sel));
mux2 #(.width(3)) destmux(.a(ir_in[11:9]), .b(3'b111), .out(destmux_out), .sel(cw.destmux_sel));

register #(.width(3)) cc
(
	.clk,
	.load(wb_ld_cc),
	.in(cc_data),
	.out(cc_out)
);

and_gate branch_stall_check
(
    .a(valid_in),
    .b(cw.branch_stall),
    .out(decode_br_stall)
);

dep_check_logic dep_check_logic
(
	.sr1(ir_in[8:6]),
	.sr2(regfilemux_out),
	.valid(valid_in),
	
	.sr1_needed(cw.sr1_needed),
	.sr2_needed(cw.sr2_needed),
	.cw(cw),
	
	.ex_ld_cc,
	.mem_ld_cc,
	.wb_ld_cc,
	
	.ex_drid,
	.mem_drid,
	.wb_drid,
	
	.ex_ld_reg,
	.mem_ld_reg,
	.wb_ld_reg,
	
	.ex_valid,
	.mem_valid,
	.wb_valid,
	
	.dep_stall
);

decode_stall_logic decode_stall_logic
(
	.dep_stall,
	.decode_br_stall,
	.execute_br_stall,
	.execute_indirect_stall,
	.mem_stall,
	.mem_br_stall,
	.icache_stall_int,
	.valid_in,
	
	.valid,
	.load_ex
);


endmodule : decode