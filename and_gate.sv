import lc3b_types::*;

module and_gate
(
    input logic a,
    input logic b,
    output logic out
);

always_comb 
    out = a and b;

endmodule : and_gate
