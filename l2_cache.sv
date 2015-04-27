import lc3b_types::*;

module l2_cache
(
    input clk,

	 input lc3b_word mem_address,
	 input lc3b_c_block mem_wdata,
	 input mem_read,
	 input mem_write,
	 
	 output lc3b_c_block mem_rdata,
	 output mem_resp,
	 
	 input lc3b_l2_block pmem_rdata,
	 input pmem_resp,
	 
	 output lc3b_word pmem_address,
	 output pmem_read,
	 output pmem_write,
	 output lc3b_l2_block pmem_wdata
);

logic hit;
logic [2:0] lru_out;

logic dirty1_out;
logic dirty2_out;
logic dirty3_out;
logic dirty4_out;

logic tag1_valid;
logic tag2_valid;
logic tag3_valid;
logic tag4_valid;

logic dirty1_in;
logic dirty2_in;
logic dirty3_in;
logic dirty4_in;
	 
logic ld_way1;
logic ld_way2;
logic ld_way3;
logic ld_way4;

logic ld_valid1;
logic ld_valid2;
logic ld_valid3;
logic ld_valid4;

logic ld_tag1;
logic ld_tag2;
logic ld_tag3;
logic ld_tag4;

logic ld_dirty1;
logic ld_dirty2;
logic ld_dirty3;
logic ld_dirty4;

logic ld_lru;
 
logic way1mux_sel;
logic way2mux_sel;
logic way3mux_sel;
logic way4mux_sel;


logic [1:0] datamux_sel;
logic [2:0] addrmux_sel;

l2_cache_datapath datapath_int
(
	.*
);

l2_cache_control control_int
(
	.*
);

endmodule : l2_cache