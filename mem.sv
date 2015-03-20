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
	input logic mem_resp,
	
	
	output lc3b_word mem_address,
	output logic mem_read,
	output logic mem_write,
	output lc3b_word mem_wdata,
	
	output logic [1:0] mem_pc_mux,
	
	output lc3b_word address,
	output lc3b_word data,
	output lc3b_control_word cw,
	output lc3b_word new_pc,
	output lc3b_word result,
	output lc3b_word ir,
	output lc3b_word dr,
	output logic valid,
	output stall
);

assign mem_address = address_in;
assign mem_read = cw_in.mem_read;
assign mem_write = cw_in.mem_write;
assign mem_wdata = result_in;


assign address = address_in;
assign data = mem_rdata;
assign cw = cw_in;
assign new_pc = new_pc_in;
assign result = result_in;
assign ir = ir_in;
assign dr = dr_in;
assign valid = valid_in;

assign stall = 1'b0;

cccomp comp
(
	.a(ir_in),
	.b(cc_in),
	.out(mem_pc_mux)
);

//TODO: add more BR logic for trap



endmodule : mem