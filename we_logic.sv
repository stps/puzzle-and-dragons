import lc3b_types::*;

module we_logic
(
    input logic write_enable,
    input logic byte_check,
    input logic rw,
    
    output logic [1:0] mem_byte_enable
);

always_comb
begin
    mem_byte_enable = 2'b11;
    if(write_enable == 1 && byte_check == 1 && rw == 1)
        mem_byte_enable = 2'b10;
    else if(write_enable == 0 && byte_check == 1 && rw == 1)
        mem_byte_enable = 2'b01;
end

endmodule : we_logic