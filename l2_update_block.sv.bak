import lc3b_types::*;

module update_block
(
		input lc3b_c_block in,
		input lc3b_c_offset offset,
		input lc3b_mem_wmask mem_byte_enable,
		input lc3b_word mem_wdata,
		
		output lc3b_c_block out
);

lc3b_c_block build;

always_comb 
begin
	build = in;
	
	if (offset == 4'b0000 || offset == 4'b0001) begin
		if (mem_byte_enable[0])
			build[7:0] = mem_wdata[7:0];
		
		if (mem_byte_enable[1])
			build[15:8] = mem_wdata[15:8];
	end
			
	else if (offset == 4'b0010 || offset == 4'b0011) begin
		if (mem_byte_enable[0])
			build[23:16] = mem_wdata[7:0];
		
		if (mem_byte_enable[1])
			build[31:24] = mem_wdata[15:8];
	end
	
	else if (offset == 4'b0100 || offset == 4'b0101) begin
		if (mem_byte_enable[0])
			build[39:32] = mem_wdata[7:0];
		
		if (mem_byte_enable[1])
			build[47:40] = mem_wdata[15:8];
	end
	
	else if (offset == 4'b0110 || offset == 4'b0111) begin
		if (mem_byte_enable[0])
			build[55:48] = mem_wdata[7:0];
		
		if (mem_byte_enable[1])
			build[63:56] = mem_wdata[15:8];
	end
	
	else if (offset == 4'b1000 || offset == 4'b1001) begin
		if (mem_byte_enable[0])
			build[71:64] = mem_wdata[7:0];
		
		if (mem_byte_enable[1])
			build[79:72] = mem_wdata[15:8];
	end
	
	else if (offset == 4'b1010 || offset == 4'b1011) begin
		if (mem_byte_enable[0])
			build[87:80] = mem_wdata[7:0];
		
		if (mem_byte_enable[1])
			build[95:88] = mem_wdata[15:8];
	end
	
	else if (offset == 4'b1100 || offset == 4'b1101) begin
		if (mem_byte_enable[0])
			build[103:96] = mem_wdata[7:0];
		
		if (mem_byte_enable[1])
			build[111:104] = mem_wdata[15:8];
	end
	
	else begin
		if (mem_byte_enable[0])
			build[119:112] = mem_wdata[7:0];
		
		if (mem_byte_enable[1])
			build[127:120] = mem_wdata[15:8];
	end
		
	out = build;
end


endmodule : update_block