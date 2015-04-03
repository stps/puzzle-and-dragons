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
	
	output lc3b_word mem_address,
	output logic mem_read,
	output logic mem_write,
	output lc3b_word mem_wdata,
	
	output logic [1:0] mem_pc_mux,
	
	//latches
	output lc3b_word address,
	output lc3b_word data,
	output lc3b_control_word cw,
	output lc3b_word new_pc,
	output lc3b_word result,
	output lc3b_word ir,
	output lc3b_word dr,
	output logic valid,
	
	//stalls originating from mem
	output logic mem_stall,
	output logic mem_br_stall,
	output logic load_wb,
	
	output logic mem_load_cc,
    output logic mem_load_regfile,
    
    output logic [1:0] mem_byte_enable
);

lc3b_word trap_logic_out;

assign mem_address = address_in;
assign mem_read = cw_in.mem_read && valid_in;
assign mem_write = cw_in.mem_write && valid_in;
assign mem_wdata = result_in;


assign address = address_in;
//assign data = mem_rdata;
assign data = trap_logic_out;
assign cw = cw_in;
assign new_pc = new_pc_in;
assign result = result_in;
assign ir = ir_in;
assign dr = dr_in;

we_logic we_logic
(
    .write_enable(address[0]),
    .byte_check(cw.lshf_enable),
    .rw(cw.mem_read || cw.mem_write),
    
    .mem_byte_enable
);

trap_logic trap_logic
(
    .dcache_out(mem_rdata),
    .mem_bit(address[0]),
    .byte_check(cw.lshf_enable),

    .trap_logic_out
);

cccomp comp
(
	.a(ir_in),
	.b(cc_in),
	.out(mem_pc_mux)
);

//TODO: add more BR logic for trap

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

	
mem_stall_logic mem_stall_logic
(
	.mem_read,
	.mem_write,
	.dep_stall(),
	.decode_br_stall(),
	.execute_br_stall(),
	.mem_br_stall(),
	.dcache_resp,
	
	.valid,
	.load_wb,
	.mem_stall
);

endmodule : mem