module arbiter_control
(
	input clk,
	
	input icache_pmem_read,
	input dcache_pmem_read,
	input dcache_pmem_write,
	
	input logic l2_resp,
	
	output logic ld_regs,
	output logic ld_mar,
	output logic ld_mdr,
	output logic marmux_sel,
	
	output logic icache_pmem_resp,
	output logic dcache_pmem_resp,
	
	output logic l2_read,
	output logic l2_write
);

enum int unsigned {
	pre_icache,
	read_icache,
	pre_dcache,
	rw_dcache
} state, next_state;

always_comb
begin : state_actions
	l2_read = 1'b0;
	l2_write = 1'b0;
	
	icache_pmem_resp = 1'b0;
	dcache_pmem_resp = 1'b0;
	
	ld_regs = 1'b0;
	ld_mdr = 1'b0;
	ld_mar = 1'b0;
	
	marmux_sel = 1'b0;
	
	case(state)
		pre_icache: begin
			if (icache_pmem_read) begin
				ld_mar = 1'b1;
				marmux_sel = 1'b0;
			end
			
			else
				ld_regs = 1'b1;
		end
		
		read_icache: begin
			l2_read = 1'b1;
			
			if (l2_resp) begin
				icache_pmem_resp = 1'b1;
				
				if (~dcache_pmem_write  && ~dcache_pmem_read)
					ld_regs = 1'b1;
			end
		end
		
		pre_dcache: begin
			ld_mar = 1'b1;
			ld_mdr = 1'b1;
			marmux_sel = 1'b1;
		end
		
		rw_dcache: begin
			l2_read = dcache_pmem_read;
			l2_write = dcache_pmem_write;
			
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
		pre_icache: begin
			if (icache_pmem_read)
				next_state = read_icache;
				
			else if (dcache_pmem_write || dcache_pmem_read)
				next_state = pre_dcache;
		end
		
		read_icache: begin
			if (l2_resp) begin
				if (dcache_pmem_write || dcache_pmem_read)
					next_state = pre_dcache;

				else
					next_state = pre_icache;
			end
		end
		  
		pre_dcache: begin
			next_state = rw_dcache;
		end


		rw_dcache: begin
			if (l2_resp)
				next_state = pre_icache;
		end
		  
		default: ;
	endcase
end

always_ff @(posedge clk)
begin : next_state_assignment
	state <= next_state;
end

endmodule : arbiter_control