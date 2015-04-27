import lc3b_types::*;

module l2_cache_lru
(
	input clk,
	input ld_lru,
	
	input [2:0] in,
	input lc3b_l2_line index,
	
	output logic [2:0] lru_out
);

logic [2:0] data [7:0];
logic [2:0] temp_lru;
logic [2:0] temp_data;

/* Initialize array */
initial
begin
    for (int i = 0; i < $size(data); i++)
    begin
        data[i] = 1'b0;
    end
end

always_ff @(posedge clk)
begin
    if (ld_lru)
        data[index] = in;
end

always_comb
begin
	lru_out = data[index];
end

endmodule : l2_cache_lru
