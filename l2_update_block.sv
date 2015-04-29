import lc3b_types::*;

module l2_update_block
(
	input lc3b_l2_block in,
	input lc3b_l2_offset offset,
	input lc3b_c_block mem_wdata,
	
	output lc3b_l2_block out
);

always_comb 
begin
	if (offset)
		out = {mem_wdata, in[127:0]};
	else
		out = {in[255:128], mem_wdata};
end


endmodule : l2_update_block