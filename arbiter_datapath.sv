import lc3b_types::*;

module arbiter_datapath
(
	input clk,

	input lc3b_word icache_pmem_address,
	input lc3b_word dcache_pmem_address,
	
	input lc3b_c_block dcache_pmem_wdata,
	
	input ld_mar,
	input ld_mdr,
	
	input marmux_sel,
	
	output lc3b_word l2_address,
	output lc3b_c_block l2_wdata
);

lc3b_word marmux_out;

mux2 #(.width(16)) marmux(.sel(marmux_sel), .a(icache_pmem_address), .b(dcache_pmem_address), .out(marmux_out));

register #(.width(16)) mar(.clk, .load(ld_mar), .in(marmux_out), .out(l2_address));
register #(.width(16)) mdr(.clk, .load(ld_mdr), .in(dcache_pmem_wdata), .out(l2_wdata));

endmodule : arbiter_datapath