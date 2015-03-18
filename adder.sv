import lc3b_types::*;

module adder #(parameter width = 16)
(
    input lc3b_word in1,
    input lc3b_word in2,
    output lc3b_word out
);

assign out = in1 + in2;

endmodule : adder
