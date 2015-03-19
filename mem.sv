import lc3b_types::*;

module mem
(
	input clk,
	
	input lcb3_word address,
	input lc3b_control_word cw,
	input lc3b_word new_pc,
	input logic [2:0] cc,
	input lc3b_word result,
	input lc3b_word ir,
	input logic [2:0] dr,
	input logic valid,
	
	input lc3b_word mem_rdata,
	input logic mem_resp,
	
	
	output lc3b_word mem_address,
	output logic mem_read,
	output logic mem_write,
	output lc3b_word mem_wdata,
	output logic valid,
	output stall
);




endmodule : mem