import lc3b_types::*;

module arbiter
(
	input clk,
	
	input icache_pmem_read,
	input lc3b_word icache_pmem_address,
	
	input dcache_pmem_read,
	input dcache_pmem_write,
	input lc3b_word dcache_pmem_address,
	
	input logic l2_resp,
	
	output logic ld_regs,
	
	output logic icache_pmem_resp,
	output logic dcache_pmem_resp,
	
	output lc3b_word l2_address,
	output logic l2_read,
	output logic l2_write
);

enum int unsigned {
	one,
	two,
	three
} state, next_state;

always_comb
begin : state_actions
	l2_read = 1'b0;
	l2_write = 1'b0;
	icache_pmem_resp = 1'b0;
	dcache_pmem_resp = 1'b0;
	l2_address = icache_pmem_address;
	ld_regs = 1'b0;
	
	case(state)
		one: begin
			if (icache_pmem_read) begin
				l2_read = 1'b1;
				
				if (l2_resp) begin
					icache_pmem_resp = 1'b1;
					
					if (~dcache_pmem_write && ~dcache_pmem_read)
						ld_regs = 1'b1;
				end
			end
			
			else
				ld_regs = 1'b1;
		end
		
		two: ;
		
		three: begin
			l2_read = dcache_pmem_read;
			l2_write = dcache_pmem_write;
			l2_address = dcache_pmem_address;
			
			if (l2_resp)
				dcache_pmem_resp = 1'b1;
				ld_regs = 1'b1;
		end
		
		default: ;
	endcase
end

always_comb
begin : next_state_logic
	next_state = state;
	
    case(state)
        one: begin
            if (dcache_pmem_write || dcache_pmem_read) begin
					if (icache_pmem_read && l2_resp)
						next_state = two;
					else
						next_state = two;
				end
				
				else
					next_state = one;
        end
		  
			two: begin
				next_state = three;
			end
		
		
        three: begin
				if (l2_resp)
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