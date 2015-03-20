import lc3b_types::*;

module arbiter
(
	input clk,
	
	input mem_read_in,
	input mem_write_in,
	
	input lc3b_word mem_address_fetch,
	input lc3b_word mem_address_mem,
	
	output logic ld_regs,
	output lc3b_word mem_address,
	output logic mem_read,
	output logic mem_write
);

enum int unsigned {
	one,
	two
} state, next_state;

always_comb
begin : state_actions
	mem_read = 1'b0;
	mem_write = 1'b0;
	mem_address = mem_address_fetch;
	ld_regs = 1'b1;
	
	case(state)
		one: begin
			if (mem_write_in || mem_read_in) begin
				mem_read = mem_read_in;
				mem_write = mem_write_in;
				mem_address = mem_address_mem;
				ld_regs = 1'b0;
			end
			
			else
				mem_read = 1'b1;
		end
		
		two: begin
			mem_read = 1'b1;
		end
		
		default: ;
	endcase
end

always_comb
begin : next_state_logic
	next_state = state;
	
    case(state)
        one: begin
            if (mem_write_in || mem_read_in)
                next_state = two;
				else
					next_state = one;
        end
		
		
        two: begin
            next_state = one;
        end
        
        default: ;
    endcase
end

always_ff @(posedge clk)
begin : next_state_assignment
	state <= next_state;
end

endmodule : arbiter