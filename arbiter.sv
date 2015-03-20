import lc3b_types::*;

module arbiter
(
	input clk,
	
	input mem_read_in,
	input mem_write_in,
	
	input lc3b_word mem_address_fetch,
	input lc3b_word mem_address_mem,
	
	output ld_regs,
	output lc3b_word mem_address,
	output mem_read,
	output mem_write
);

