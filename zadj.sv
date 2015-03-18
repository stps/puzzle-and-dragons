import lc3b_types::*;

/*
 * zEXT[offset-n << 1]
 */
module zadj #(parameter width = 8)
(
    input [width-1:0] in,
    output lc3b_word out
);

logic [14:0] zext;

assign zext = {7'b0000000, in};
assign out = {zext, 1'b0};

endmodule : zadj
