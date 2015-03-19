import lc3b_types::*;

module decode
(
	input lc3b_word npc_in,
	input lc3b_word ir_in,
	input valid_in,
	
	output lc3b_word npc, 
	output lc3b_control_word cw,
	output lc3b_word ir,
	output lc3b_word sr1,
	output lc3b_word sr2,
	output lc3b_nzp cc,
	output lc3b_reg dr,
	output logic valid
);


