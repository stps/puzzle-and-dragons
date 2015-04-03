import lc3b_types::*;

module mux16
(
	input lc3b_c_offset sel,
	input lc3b_c_block in,
	
	output lc3b_word out
);

always_comb
begin
	if (sel == 4'b0000 || sel == 4'b0001)
		out = in[15:0];
	else if (sel == 4'b0010 || sel == 4'b0011)
		out = in[31:16];
	else if (sel == 4'b0100 || sel == 4'b0101)
		out = in[47:32];
	else if (sel == 4'b0110 || sel == 4'b0111)
		out = in[63:48];
	else if (sel == 4'b1000 || sel == 4'b1001)
		out = in[79:64];
	else if (sel == 4'b1010 || sel == 4'b1011)
		out = in[95:80];
	else if (sel == 4'b1100 || sel == 4'b1101)
		out = in[111:96];
	else 
		out = in[127:112];
end
	
endmodule : mux16
