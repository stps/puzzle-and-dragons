import lc3b_types::*;

module cccomp
(
			input lc3b_word a,
			input lc3b_nzp b,
			output logic out
);
         always_comb
         begin
			if (a[15:12] == 4'b0000)
			begin
             if (a[11] == 1 && b == 3'b100)
					out = 1;
				else if (a[10] == 1 && b == 3'b010)
					out = 1;
				else if (a[9] == 1 && b == 3'b001)
					out = 1;
				else
					out = 0;
			end
			else
				out = 0;
         end
endmodule : cccomp