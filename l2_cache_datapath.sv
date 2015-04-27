import lc3b_types::*;

module l2_cache_datapath
(
    input clk,
	 input lc3b_word mem_address,
	 input lc3b_c_block mem_wdata,
	 input lc3b_l2_block pmem_rdata,
	 
	 input dirty1_in,
	 input dirty2_in,
	 input dirty3_in,
	 input dirty4_in,
	 
	 input ld_way1,
	 input ld_way2,
	 input ld_way3,
	 input ld_way4,
	 
	 input ld_valid1,
	 input ld_valid2,
	 input ld_valid3,
	 input ld_valid4,
	 
	 input ld_tag1, 
	 input ld_tag2,
	 input ld_tag3, 
	 input ld_tag4,
	 
	 input ld_dirty1,
	 input ld_dirty2,
	 input ld_dirty3,
	 input ld_dirty4,
	 
	 input ld_lru,
	 
	 input way1mux_sel,
	 input way2mux_sel,
	 input way3mux_sel,
	 input way4mux_sel,
	 
	 input [1:0] datamux_sel,
	 input [2:0] addrmux_sel,
	 
	 output logic hit,
	 output [2:0] lru_out,
	 
	 output logic dirty1_out,
	 output logic dirty2_out,
	 output logic dirty3_out,
	 output logic dirty4_out,
	 
	 output logic tag1_valid,
	 output logic tag2_valid,
	 output logic tag3_valid,
	 output logic tag4_valid,
	 
	 output lc3b_word pmem_address,
	 output lc3b_l2_block pmem_wdata,
	 output lc3b_c_block mem_rdata
);

logic valid1_out;
logic valid2_out;
logic valid3_out;
logic valid4_out;

logic tag1_equals;
logic tag2_equals;
logic tag3_equals;
logic tag4_equals;

logic [2:0] temp_lru;

lc3b_l2_offset offset; 
lc3b_l2_line line;
lc3b_l2_tag tag;

lc3b_l2_block way1mux_out;
lc3b_l2_block way2mux_out;
lc3b_l2_block way3mux_out;
lc3b_l2_block way4mux_out;
lc3b_l2_block way1_out;
lc3b_l2_block way2_out;
lc3b_l2_block way3_out;
lc3b_l2_block way4_out;
lc3b_l2_block datamux_out;
lc3b_l2_block update_out;
lc3b_l2_tag tag1_out;
lc3b_l2_tag tag2_out;
lc3b_l2_tag tag3_out;
lc3b_l2_tag tag4_out;

assign offset = mem_address[4];
assign line = mem_address[7:5];
assign tag = mem_address[15:8];
assign pmem_wdata = datamux_out;

// way1
mux2 #(.width(256)) way1_mux(.sel(way1mux_sel), .a(update_out), .b(pmem_rdata), .out(way1mux_out));
array #(.width(256)) way1_array(.clk, .write(ld_way1), .index(line), .datain(way1mux_out), .dataout(way1_out));

// way2
mux2 #(.width(256)) way2_mux(.sel(way2mux_sel), .a(update_out), .b(pmem_rdata), .out(way2mux_out));
array #(.width(256)) way2_array(.clk, .write(ld_way2), .index(line), .datain(way2mux_out), .dataout(way2_out));

// way3
mux2 #(.width(256)) way3_mux(.sel(way3mux_sel), .a(update_out), .b(pmem_rdata), .out(way3mux_out));
array #(.width(256)) way3_array(.clk, .write(ld_way3), .index(line), .datain(way3mux_out), .dataout(way3_out));

// way4
mux2 #(.width(256)) way4_mux(.sel(way4mux_sel), .a(update_out), .b(pmem_rdata), .out(way4mux_out));
array #(.width(256)) way4_array(.clk, .write(ld_way4), .index(line), .datain(way4mux_out), .dataout(way4_out));


// data
mux4 #(.width(256)) data_mux(.sel(datamux_sel), .a(way1_out), .b(way2_out), .c(way3_out), .d(way4_out), .out(datamux_out));

mux2 #(.width(128)) word_mux(.sel(offset), .a(datamux_out[127:0]), .b(datamux_out[255:128]), .out(mem_rdata));
					
l2_update_block update(.in(datamux_out), .offset, .mem_wdata, .out(update_out));


// valid bit arrays
array #(.width(1)) valid1_array(.clk, .write(ld_valid1), .index(line), .datain(1'b1), .dataout(valid1_out));
array #(.width(1)) valid2_array(.clk, .write(ld_valid2), .index(line), .datain(1'b1), .dataout(valid2_out));
array #(.width(1)) valid3_array(.clk, .write(ld_valid3), .index(line), .datain(1'b1), .dataout(valid3_out));
array #(.width(1)) valid4_array(.clk, .write(ld_valid4), .index(line), .datain(1'b1), .dataout(valid4_out));

// dirty bit arrays
array #(.width(1)) dirty1_array(.clk, .write(ld_dirty1), .index(line), .datain(dirty1_in), .dataout(dirty1_out));
array #(.width(1)) dirty2_array(.clk, .write(ld_dirty2), .index(line), .datain(dirty2_in), .dataout(dirty2_out));
array #(.width(1)) dirty3_array(.clk, .write(ld_dirty3), .index(line), .datain(dirty3_in), .dataout(dirty3_out));
array #(.width(1)) dirty4_array(.clk, .write(ld_dirty4), .index(line), .datain(dirty4_in), .dataout(dirty4_out));

//tag arrays
array #(.width(8)) tag1_array(.clk, .write(ld_tag1), .index(line), .datain(tag), .dataout(tag1_out));
array #(.width(8)) tag2_array(.clk, .write(ld_tag2), .index(line), .datain(tag), .dataout(tag2_out));
array #(.width(8)) tag3_array(.clk, .write(ld_tag3), .index(line), .datain(tag), .dataout(tag3_out));
array #(.width(8)) tag4_array(.clk, .write(ld_tag4), .index(line), .datain(tag), .dataout(tag4_out));

// LRU
l2_cache_lru lru(.clk, .ld_lru, .in(temp_lru), .index(line), .lru_out);

//address mux
mux5 address_mux
(
	.sel(addrmux_sel), 
	.a({mem_address[15:5], 5'b000}), 
	.b({tag1_out, line, 5'b0000}), 
	.c({tag2_out, line, 5'b0000}), 
	.d({tag3_out, line, 5'b0000}), 
	.e({tag4_out, line, 5'b0000}), 
	.f(pmem_address)
);

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
		
	if (tag3_out == tag)
		tag3_equals = 1;
	else
		tag3_equals = 0;
		
	if (tag4_out == tag)
		tag4_equals = 1;
	else
		tag4_equals = 0;
		
		
	if (valid1_out && tag1_equals)
		tag1_valid = 1;
	else
		tag1_valid = 0;
	
	if (valid2_out && tag2_equals)
		tag2_valid = 1;
	else
		tag2_valid = 0;
		
	if (valid3_out && tag3_equals)
		tag3_valid = 1;
	else
		tag3_valid = 0;
	
	if (valid4_out && tag4_equals)
		tag4_valid = 1;
	else
		tag4_valid = 0;
		
	if (tag1_valid || tag2_valid || tag3_valid || tag4_valid)
		hit = 1;
	else 
		hit = 0;
		
	if (tag1_valid || ld_way1)
		temp_lru = {2'b11, lru_out[0]};
	else if (tag2_valid || ld_way2)
		temp_lru = {2'b10, lru_out[0]};
	else if (tag3_valid || ld_way3)
		temp_lru = {1'b0, lru_out[1], 1'b1};
	else if (tag4_valid || ld_way4)
		temp_lru = {1'b0, lru_out[1], 1'b0};
	else 
		temp_lru = lru_out;
end

endmodule : l2_cache_datapath