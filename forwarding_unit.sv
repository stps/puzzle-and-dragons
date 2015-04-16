import lc3b_types::*;

module forwarding_unit
(
    input logic ex_mem_load_regfile,
    input logic mem_wb_load_regfile,
    input lc3b_reg ex_mem_dr_out,
    input lc3b_reg mem_wb_dr_out,
    input lc3b_reg de_ex_rs_out,
    input lc3b_reg de_ex_rt_out,
    
    output [1:0] forwardA_mux_sel,
    output [1:0] forwardB_mux_sel
);

always_comb
begin
    if(mem_wb_load_regfile && mem_wb_dr_out != 0 && !(ex_mem_load_regfile && (ex_mem_dr_out != 0))
        && ex_mem_dr_out != de_ex_rs_out && mem_wb_dr_out == de_ex_rs_out)
        forwardA_mux_sel = 2'b01;
    else if(ex_mem_load_regfile && ex_mem_dr_out != 0 && ex_mem_dr_out == de_ex_rs_out)
        forwardA_mux_sel = 2'b10;
    else forwardA_mux_sel = 2'b00;

    if(mem_wb_load_regfile && mem_wb_dr_out != 0 && !(ex_mem_load_regfile && (ex_mem_dr_out != 0))
        && ex_mem_dr_out != de_ex_rt_out && mem_wb_dr_out == de_ex_rt_out)
        forwardB_mux_sel = 2'b01;
    else if(ex_mem_load_regfile && ex_mem_dr_out != 0 && ex_mem_dr_out == de_ex_rt_out)
        forwardB_mux_sel = 2'b10;
    else forwardB_mux_sel = 2'b00;
end

endmodule : forwarding_unit