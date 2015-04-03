module mux2 #(parameter width = 16)
(
	input sel,
	input [width-1:0] a, b,
	output logic [width-1:0] out
);

always_comb
begin
	if (sel == 0)
		 out = a;
	else
		 out = b;
end
endmodule : mux2