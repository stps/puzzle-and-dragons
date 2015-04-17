module l2_cache_control
(
    input clk,
	 input mem_read,
	 input mem_write,
	 input hit,
	 input pmem_resp,
	 input lru_out,
	 input dirty1_out,
	 input dirty2_out,
	 input tag1_valid,
	 input tag2_valid,
	 
	 output logic dirty1_in,
	 output logic dirty2_in,
	 
	 output logic ld_way1,
	 output logic ld_way2,
	 output logic ld_valid1,
	 output logic ld_valid2,
	 output logic ld_tag1, 
	 output logic ld_tag2,
	 output logic ld_dirty1,
	 output logic ld_dirty2,
	 output logic ld_lru,
	 
	 output logic way1mux_sel,
	 output logic way2mux_sel,
	 output logic datamux_sel,
	 output logic [1:0] addrmux_sel,
	 
	 output logic pmem_read,
	 output logic pmem_write,
	 output logic mem_resp
);

enum int unsigned {
    /* List of states */
	 idle,
	 read,
	 write_mem,
	 resp
} state, next_states;

always_comb
begin : state_actions
	dirty1_in = 1'b0;
	dirty2_in = 1'b0;
	
	ld_way1 = 1'b0;
	ld_way2 = 1'b0;
	ld_valid1 = 1'b0;
	ld_valid2 = 1'b0;
	ld_tag1 = 1'b0;
	ld_tag2 = 1'b0;
	ld_dirty1 = 1'b0;
	ld_dirty2 = 1'b0;
	ld_lru = 1'b0;
	
	way1mux_sel = 1'b0;
	way2mux_sel = 1'b0;
	datamux_sel = tag2_valid;
	addrmux_sel = 2'b00;
	
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	mem_resp = 1'b0;
	
	case (state)
		idle: begin
			if (hit && mem_read) begin
				mem_resp = 1'b1;
				ld_lru = 1'b1;
			end
			
			if (hit && mem_write) begin
				if (tag1_valid) begin
					ld_way1 = 1'b1;
					ld_dirty1 = 1'b1;
					dirty1_in = 1'b1;
				end
				
				else begin
					ld_way2 = 1'b1;
					ld_dirty2 = 1'b1;
					dirty2_in = 1'b1;
				end
			end
		end
		
		read: begin
			if (~hit) begin
				if (~lru_out) begin
					if (~dirty1_out) begin
						pmem_read = 1'b1;
						way1mux_sel = 1'b1;
	
						if (pmem_resp) begin
							ld_valid1 = 1'b1;
							ld_tag1 = 1'b1;
							
							if (mem_read)
								ld_lru = 1'b1;
							ld_way1 = 1'b1;
						end
					end
					
					else begin
						datamux_sel = lru_out;
						addrmux_sel = 2'b01;
					end
				end
				
				else begin
					if (~dirty2_out) begin
						pmem_read = 1'b1;
						way2mux_sel = 1'b1;
						
						if (pmem_resp) begin
							ld_valid2 = 1'b1;
							ld_tag2 = 1'b1;
							
							if (mem_read)
								ld_lru = 1'b1;
							ld_way2 = 1'b1;
						end
					end
					
					else begin
						datamux_sel = lru_out;
						addrmux_sel = 2'b10;
					end
				end
			end
		end
		
		write_mem: begin
			pmem_write = 1'b1;
			datamux_sel = lru_out;
			
			if (~lru_out)
				addrmux_sel = 2'b01;
			else
				addrmux_sel = 2'b10;
			
			if (pmem_resp) begin
				if (~lru_out)
					ld_dirty1 = 1'b1;
				else
					ld_dirty2 = 1'b1;
			end
		end
		
		resp: begin
			mem_resp = 1'b1;
			ld_lru = 1'b1;
		end
		
		default: ;
	endcase
end

always_comb
begin : next_state_logic
	next_states = state;
	
	case (state) 
		idle: begin
			if (mem_read && ~hit)
				next_states = read;
				
			if (mem_write && hit)
				next_states = resp;
				
			if (mem_write && ~hit)
				next_states = read;
		end
				
		read: begin
			if (~lru_out) begin
				if (dirty1_out)
					next_states = write_mem;
				else if (pmem_resp)
					if (mem_read)
						next_states = resp;
					else 
						next_states = idle;
			end
			
			else begin
				if (dirty2_out)
					next_states = write_mem;
				else if (pmem_resp)
					if (mem_read)
						next_states = resp;
					else 
						next_states = idle;
			end
		end
		
		resp: begin
			next_states = idle;
		end
		
		write_mem: begin
			if (pmem_resp) begin
				next_states = read;
			end
		end
		
		default: begin
			next_states = idle;
		end
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_states;
end
	
endmodule : l2_cache_control