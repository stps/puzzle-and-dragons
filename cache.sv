import lc3b_types::*;

module cache
(
    input clk,

	 input lc3b_word mem_address,
	 input lc3b_word mem_wdata,
	 input mem_read,
	 input mem_write,
	 
	 input lc3b_mem_wmask mem_byte_enable,
	 output lc3b_word mem_rdata,
	 output mem_resp,
	 
	 input lc3b_c_block pmem_rdata,
	 input pmem_resp,
	 
	 output lc3b_word pmem_address,
	 output pmem_read,
	 output pmem_write,
	 output lc3b_c_block pmem_wdata
);

logic hit;
logic dirty1_out;
logic dirty2_out;
logic lru_out;
logic tag1_valid;
logic tag2_valid;

logic dirty1_in;
logic dirty2_in;
	 
logic ld_way1;
logic ld_way2;
logic ld_valid1;
logic ld_valid2;
logic ld_tag1;
logic ld_tag2;
logic ld_dirty1;
logic ld_dirty2;
logic ld_lru;
 
logic way1mux_sel;
logic way2mux_sel;
logic datamux_sel;
logic [1:0] addrmux_sel;

cache_datapath datapath_int
(
	.*
);

cache_control control_int
(
	.*
);

endmodule : cache