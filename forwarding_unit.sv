import lc3b_types::*;

module forwarding_unit
(
    input lc3b_reg ex_mem_dr_out,
    input lc3b_reg mem_wb_dr_out,
    input lc3b_reg de_ex_rs_out,
    input lc3b_reg de_ex_rt_out,
    
    output [1:0] forwardA_mux_sel,
    output [1:0] forwardB_mux_sel
);

always_comb
begin
    forwardA_mux_sel = 2'b00;
    forwardB_mux_sel = 2'b00;
    
end

endmodule : forwarding_unit