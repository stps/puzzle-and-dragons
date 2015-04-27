import lc3b_types::*;

module alu
(
    input logic clk,
    input lc3b_aluop aluop,
    input lc3b_word a, b,
    output lc3b_word f
);

lc3b_word div_output;
lc3b_word mult_output;

lpm_divide  #(.lpm_widthn(16), .lpm_widthd(16), .lpm_pipeline(3)) lpm_divide_int
(
    .clock(clk),
    .quotient(div_output),
    .numer(a),
    .denom(b)
);

lpm_mult #(.lpm_widthb(16), .lpm_widtha(16), .lpm_widthp(16), .lpm_pipeline(3)) lpm_mult_int
(
    .clock(clk),
    .result(mult_output),
    .dataa(a),
    .datab(b)
);

always_comb
begin
    case (aluop)
        alu_add: f = a + b;
        alu_and: f = a & b;
        alu_not: f = ~a;
        alu_pass: f = b;
        alu_sll: f = a << b;
        alu_srl: f = a >> b;
        alu_sra: f = $signed(a) >>> b;
        //lc-3x
        alu_sub: f = a - b;
        alu_mul: f = mult_output;
        alu_div: f = div_output;
        alu_or: f = a | b;
        alu_xor: f = a ^ b;
        default: $display("Unknown aluop");
    endcase
end

endmodule : alu
