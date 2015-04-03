import lc3b_types::*;

//left shifts when enable bit is low
module cond_lshf
(
    input logic enable,
    input lc3b_word in,
    
    output lc3b_word out
);

always_comb
begin
    out = in;
    if(enable == 0)
        out = {in, 1'b0};
end

endmodule : cond_lshf