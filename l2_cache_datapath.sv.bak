import lc3b_types::*;

module cache_datapath
(
    input clk,
	 input lc3b_word mem_address,
	 input lc3b_word mem_wdata,
	 input lc3b_c_block pmem_rdata,
	 input lc3b_mem_wmask mem_byte_enable,
	 
	 input dirty1_in,
	 input dirty2_in,
	 
	 input ld_way1,
	 input ld_way2,
	 input ld_valid1,
	 input ld_valid2,
	 input ld_tag1, 
	 input ld_tag2,
	 input ld_dirty1,
	 input ld_dirty2,
	 input ld_lru,
	 
	 input way1mux_sel,
	 input way2mux_sel,
	 input datamux_sel,
	 input [1:0] addrmux_sel,
	 
	 output logic hit,
	 output logic lru_out,
	 output logic dirty1_out,
	 output logic dirty2_out,
	 output logic tag1_valid,
	 output logic tag2_valid,
	 
	 output lc3b_word pmem_address,
	 output lc3b_c_block pmem_wdata,
	 output lc3b_word mem_rdata
);

logic valid1_out;
logic valid2_out;
logic tag1_equals;
logic tag2_equals;

lc3b_c_offset offset; 
lc3b_c_line line;
lc3b_c_tag tag;

lc3b_c_block way1mux_out;
lc3b_c_block way2mux_out;
lc3b_c_block way1_out;
lc3b_c_block way2_out;
lc3b_c_block datamux_out;
lc3b_c_block update_out;
lc3b_c_tag tag1_out;
lc3b_c_tag tag2_out;

assign offset = mem_address[3:0];
assign line = mem_address[6:4];
assign tag = mem_address[15:7];
assign pmem_wdata = datamux_out;

// way1
mux2 #(.width(128)) way1_mux(.sel(way1mux_sel), .a(update_out), .b(pmem_rdata), .out(way1mux_out));
array way1_array(.clk, .write(ld_way1), .index(line), .datain(way1mux_out), .dataout(way1_out));

// way2
mux2 #(.width(128)) way2_mux(.sel(way2mux_sel), .a(update_out), .b(pmem_rdata), .out(way2mux_out));
array way2_array(.clk, .write(ld_way2), .index(line), .datain(way2mux_out), .dataout(way2_out));

// data
mux2 #(.width(128)) data_mux(.sel(datamux_sel), .a(way1_out), .b(way2_out), .out(datamux_out));

mux16 word_mux(.sel(offset), .in(datamux_out), .out(mem_rdata));
					
update_block update(.in(datamux_out), .offset, .mem_byte_enable, .mem_wdata, .out(update_out));


// valid bit arrays
array #(.width(1)) valid1_array(.clk, .write(ld_valid1), .index(line), .datain(1'b1), .dataout(valid1_out));
array #(.width(1)) valid2_array(.clk, .write(ld_valid2), .index(line), .datain(1'b1), .dataout(valid2_out));

// dirty bit arrays
array #(.width(1)) dirty1_array(.clk, .write(ld_dirty1), .index(line), .datain(dirty1_in), .dataout(dirty1_out));
array #(.width(1)) dirty2_array(.clk, .write(ld_dirty2), .index(line), .datain(dirty2_in), .dataout(dirty2_out));

//tag arrays
array #(.width(9)) tag1_array(.clk, .write(ld_tag1), .index(line), .datain(tag), .dataout(tag1_out));
array #(.width(9)) tag2_array(.clk, .write(ld_tag2), .index(line), .datain(tag), .dataout(tag2_out));

// LRU
array #(.width(1)) lru (.clk, .write(ld_lru), .index(line), .datain(!tag2_valid), .dataout(lru_out));

//address mux
mux3 address_mux(.sel(addrmux_sel), .a({mem_address[15:4], 4'b000}), .b({tag1_out, line, 4'b0000}), .c({tag2_out, line, 4'b0000}), .f(pmem_address));

always_comb
begin
	if (tag1_out == tag)
		tag1_equals = 1;
	else
		tag1_equals = 0;
		
	if (tag2_out == tag)
		tag2_equals = 1;
	else
		tag2_equals = 0;
		
	if (valid1_out && tag1_equals)
		tag1_valid = 1;
	else
		tag1_valid = 0;
	
	if (valid2_out && tag2_equals)
		tag2_valid = 1;
	else
		tag2_valid = 0;
		
	if (tag1_valid || tag2_valid)
		hit = 1;
	else 
		hit = 0;
end

endmodule : cache_datapath