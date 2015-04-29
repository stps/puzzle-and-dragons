import lc3b_types::*;

module mem
(
	input clk,
	
	input lc3b_word address_in,
	input lc3b_control_word cw_in,
	input lc3b_word new_pc_in,
	input logic [2:0] cc_in,
	input lc3b_word result_in,
	input lc3b_word ir_in,
	input logic [2:0] dr_in,
	input logic valid_in,
	
	input lc3b_word mem_rdata,
	input dcache_resp,
	input lc3b_word indirect_data_in,
	input lc3b_word indirect_reg_in,
	input lc3b_word indirect_result_in,
	
	input logic leapfrog_load,
	input logic leapfrog_stall,
	
	output lc3b_word mem_address,
	output logic mem_read,
	output logic mem_write,
	output lc3b_word mem_wdata,
	
	output logic [1:0] mem_pc_mux,
	
	//latches
	output lc3b_word data,
	output lc3b_control_word cw,
	output lc3b_word new_pc,
	output lc3b_word result,
	output lc3b_word ir,
	output lc3b_word dr,
	output logic valid,
	
	input logic icache_stall_int,
	
	//stalls originating from mem
	output logic mem_stall,
	output logic mem_br_stall,
	output logic load_wb,
	
	output logic mem_load_cc,
   output logic mem_load_regfile,
    
   output logic [1:0] mem_byte_enable
);

logic indirect_op;
lc3b_word trap_logic_out;

logic [1:0] br_pcmux_sel;

assign mem_read = cw_in.mem_read && valid_in || cw_in.mem_read && cw_in.indirectaddrmux_sel;
assign mem_write = cw_in.mem_write && valid_in || cw_in.mem_write && cw_in.indirectaddrmux_sel;

assign data = trap_logic_out;
assign cw = cw_in;
assign new_pc = new_pc_in;
assign result = result_in;
assign ir = ir_in;

always_comb begin
	if (cw_in.opcode == op_sti || cw_in.opcode == op_ldi)
		indirect_op = 1'b1;
	else
		indirect_op = 1'b0;
		
	if ((cw_in.opcode == op_jsr || cw_in.opcode == op_jmp) && valid_in == 1'b1)
		mem_pc_mux = 2'b01;
	else if (cw_in.opcode == op_trap && valid_in == 1'b1)
		mem_pc_mux = 2'b10;
	else if (cw_in.opcode == op_br && valid_in == 1'b1)
		mem_pc_mux = br_pcmux_sel;
	else
		mem_pc_mux = 2'b00;
		
	if (cw_in.opcode == op_stb)
		mem_wdata = {result_in[7:0], result_in[7:0]};
	else if (cw_in.indirectaddrmux_sel)
		mem_wdata = indirect_result_in;
	else
		mem_wdata = result_in;
end


mux2 indirectaddr_mux
(
	.sel(cw_in.indirectaddrmux_sel),
	.a(address_in),
	.b(indirect_data_in),
	.out(mem_address)
);


mux2 indirectreg_mux
(
	.sel(cw_in.indirectaddrmux_sel),
	.a(dr_in),
	.b(indirect_reg_in),
	.out(dr)
);

we_logic we_logic
(
    .write_enable(mem_address[0]),
    .byte_check(cw.lshf_enable),
    .rw(cw.mem_read || cw.mem_write),
    
    .mem_byte_enable
);

trap_logic trap_logic
(
    .dcache_out(mem_rdata),
    .mem_bit(mem_address[0]),
    .byte_check(cw.lshf_enable),

    .trap_logic_out
);

cccomp comp
(
	.a(ir_in),
	.b(cc_in),
	.out(br_pcmux_sel)
);

and_gate load_cc_check
(
    .a(valid_in),
    .b(cw_in.load_cc),
    .out(mem_load_cc)
);

and_gate load_regfile_check
(
    .a(valid_in),
    .b(cw_in.load_regfile),
    .out(mem_load_regfile)
);

and_gate branch_stall_check
(
    .a(valid_in),
    .b(cw_in.branch_stall),
    .out(mem_br_stall)
);

	
mem_stall_logic mem_stall_logic
(
	.mem_read,
	.mem_write,
	.dep_stall(),
	.decode_br_stall(),
	.execute_br_stall(),
	.mem_br_stall(),
	.dcache_resp,
	.indirect_op,
	.valid_in,
	.cw,
	
	.leapfrog_load,
	.leapfrog_stall,
	
	.valid,
	.load_wb,
	.mem_stall,
	.icache_stall_int
);

endmodule : mem