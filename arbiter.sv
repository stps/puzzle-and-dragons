import lc3b_types::*;

module arbiter
(
	input clk,
	
	input icache_read,
	input lc3b_word icache_address,
	
	input dcache_read,
	input dcache_write,
	input lc3b_word dcache_address,
	
	input logic pmem_resp,
	
	output logic ld_regs,
	
	output logic icache_pmem_resp,
	output logic dcache_pmem_resp,
	
	output lc3b_word pmem_address,
	output logic pmem_read,
	output logic pmem_write
);

enum int unsigned {
	one,
	two,
	three
} state, next_state;

always_comb
begin : state_actions
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	icache_pmem_resp = 1'b0;
	dcache_pmem_resp = 1'b0;
	pmem_address = icache_address;
	ld_regs = 1'b1;
	
	case(state)
		one: begin
			if (icache_read) begin
				pmem_read = 1'b1;
				
				if (pmem_resp)
					icache_pmem_resp = 1'b1;
			end
					
			
			if (dcache_write || dcache_read)
				ld_regs = 1'b0;
		end
		
		two: begin
			ld_regs = 1'b0;
		end
		
		three: begin
			pmem_read = dcache_read;
			pmem_write = dcache_write;
			pmem_address = dcache_address;
			
			if (pmem_resp)
				dcache_pmem_resp = 1'b1;
		end
		
		default: ;
	endcase
end

always_comb
begin : next_state_logic
	next_state = state;
	
    case(state)
        one: begin
            if (dcache_write || dcache_read) begin
					if (pmem_resp)
						next_state = two;
				end
				
				else
					next_state = one;
        end
		  
			two: begin
				next_state = three;
			end
		
		
        three: begin
				if (pmem_resp)
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