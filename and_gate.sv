import lc3b_types::*;

module and_gate
(
    input logic a,
    input logic b,
    output logic out
);

assign out = a & b;

endmodule : and_gate
