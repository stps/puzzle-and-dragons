module mux4 #(parameter width = 16)
(
			input [1:0] sel,
         input [width-1:0] a, b, c, d,
         output logic [width-1:0] out
);
         always_comb
         begin
            if (sel == 2'b00)
               out = a;
				else if (sel == 2'b01)
					out = b;
				else if (sel == 2'b10)
					out = c;
				else
					out = d;
         end
         endmodule : mux4