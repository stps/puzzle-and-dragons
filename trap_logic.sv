import lc3b_types::*;

module trap_logic
(
    input lc3b_word dcache_out,
    input logic mem_bit,
    input logic byte_check,

    output lc3b_word trap_logic_out
);

always_comb
begin
    trap_logic_out = dcache_out;
    if(byte_check == 1) begin
        if(mem_bit == 1)
            trap_logic_out = {8'b00000000, dcache_out[15:8]};
        else if (mem_bit == 0)
            trap_logic_out = {8'b00000000, dcache_out[7:0]};
    end
end

endmodule : trap_logic