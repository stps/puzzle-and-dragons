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
ctrl.aluop = alu_pass;
ctrl.load_cc = 1'b0;
ctrl.load_regfile = 1'b0;
ctrl.sr2mux_sel = 1'b0;
ctrl.mem_read = 1'b0;
ctrl.mem_write = 1'b0;
ctrl.addr1mux_sel = 1'b0;
ctrl.addr2mux_sel = 2'b00;
ctrl.drmux_sel = 1'b0;
ctrl.regfilemux_sel = 1'b0;

/* Assign control signals based on opcode */
case(opcode)
    op_add: begin
        ctrl.aluop = alu_add;
        ctrl.load_regfile = 1'b1;
        if(imm_check == 0) begin
            ctrl.sr2mux_sel = 1'b0;
        end
        else begin
            ctrl.sr2mux_sel = 1'b1;
        end
        ctrl.load_cc = 1'b1;
    end
    
    op_and: begin
        ctrl.aluop = alu_and;
        ctrl.load_regfile = 1'b1;
        if(imm_check == 0) begin
            ctrl.sr2mux_sel = 1'b0;
        end
        else begin
            ctrl.sr2mux_sel = 1'b1;
        end
        ctrl.load_cc = 1'b1;
    end
    
    op_not: begin
        ctrl.aluop = alu_not;
        ctrl.load_regfile = 1'b1;
        ctrl.load_cc = 1'b1;
    end
    
    op_ldr: begin
        ctrl.mem_read = 1'b1;
        ctrl.load_cc = 1'b1;
        ctrl.addr1mux_sel = 1'b1;
        ctrl.addr2mux_sel = 2'b01;
    end
    
    op_str: begin
        ctrl.mem_write = 1'b1;
        ctrl.addr1mux_sel = 1'b1;
        ctrl.addr2mux_sel = 2'b01;
    end
    
    op_br: begin
    end

    
    default: begin
        ctrl = 0; /* Unknown opcode, set control word to zero */
    end
endcase
end
endmodule : control_rom