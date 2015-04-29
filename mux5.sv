module mux5 #(parameter width = 16)
(
	input [2:0] sel,
	input [width-1:0] a, b, c, d, e,
	output logic [width-1:0] f
);

always_comb
begin
	if (sel == 3'b000)
		f = a;
	else if (sel == 3'b001)
		f = b;
	else if (sel == 3'b010)
		f = c;
	else if (sel == 3'b011)
		f = d;
	else 
		f = e;
end
	
endmodule : mux5
