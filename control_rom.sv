import lc3b_types::*;

module control_rom
(
    input lc3b_opcode opcode,
    input logic imm_check,
    output lc3b_control_word ctrl
);

always_comb
begin

/* Default assignments */
ctrl.opcode = opcode;
ctrl.load_cc = 0;
ctrl.load_regfile = 0;
/* ... other defaults ... */

/* Assign control signals based on opcode */
case(opcode)
    op_add: begin
        ctrl.aluop = alu_add;
        ctrl.load_regfile = 1;
        if(imm_check == 0)
        begin
            /* DR <= sr1 + sr2 */
            ctrl.sr2mux_sel = 0;
        end
        else
        begin
            /* DR <= sr1 + SEXT(imm5) */
            ctrl.sr2mux_sel = 1;
        end
        ctrl.load_cc = 1;
    end
    
    op_and: begin
        ctrl.aluop = alu_and;
        ctrl.load_regfile = 1;
        if(imm_check == 0)
        begin
            /* DR <= sr1 & sr2 */
            ctrl.sr2mux_sel = 0;
        end
        else
        begin
            /* DR <= sr1 & SEXT(imm5) */
            ctrl.sr2mux_sel = 1;
        end
        ctrl.load_cc = 1;
    end
    
    op_not: begin
        ctrl.aluop = alu_not;
        ctrl.load_regfile = 1;
        ctrl.load_cc = 1;
    end
    
    op_ldr: begin
    end
    
    op_str: begin
    end
    
    op_br: begin
    end
    
    default: begin
        ctrl = 0; /* Unknown opcode, set control word to zero */
    end
endcase
end
endmodule : control_rom