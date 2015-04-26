import lc3b_types::*;

module leapfrog_logic
(
	input logic mem_stall,
	input lc3b_control_word cw,
	input lc3b_reg mem_dr,
	input lc3b_reg sr1,
	input lc3b_reg sr2,
	
	output logic leapfrog_load,
	output logic leapfrog_stall
);



always_comb
begin
	leapfrog_load = 1'b0;
	leapfrog_stall = 1'b0;
	
	if (mem_stall == 1'b1 && (cw.mem_read == 1'b1 || cw.mem_write == 1'b1))
	begin
		leapfrog_stall = 1'b1;
		leapfrog_load = 1'b1;
		if (mem_dr == sr1 || mem_dr == sr2)
		begin
			leapfrog_load = 1'b0;
			leapfrog_stall = 1'b1;
		end
	end
end

endmodule : leapfrog_logic