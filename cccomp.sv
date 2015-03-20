import lc3b_types::*;

module cccomp
(
			input lc3b_reg a,
			input lc3b_nzp b,
			output logic out
);
         always_comb
         begin
             if (a[2] == 1 && b == 3'b100)
					out = 1;
				else if (a[1] == 1 && b == 3'b010)
					out = 1;
				else if (a[0] == 1 && b == 3'b001)
					out = 1;
				else
					out = 0;
         end
endmodule : cccomp