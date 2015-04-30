import lc3b_types::*;

module leap_control_logic
(
	input logic leapfrog_load,
	input logic [1:0] leap_br_pcmux_sel,
	input lc3b_control_word cw_in,
	input logic valid_in,
	
	output logic [1:0] leap_pc_mux
	
);
         always_comb
         begin
				if ((cw_in.opcode == op_jsr || cw_in.opcode == op_jmp) && valid_in == 1'b1)
					leap_pc_mux = 2'b01;
				else if (cw_in.opcode == op_trap && valid_in == 1'b1)
					leap_pc_mux = 2'b10;
				else if (cw_in.opcode == op_br && valid_in == 1'b1)
					leap_pc_mux = leap_br_pcmux_sel;
				else
					leap_pc_mux = 2'b00;			
         end
endmodule : leap_control_logic