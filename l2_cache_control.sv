module l2_cache_control
(
    input clk,
	 input mem_read,
	 input mem_write,
	 input pmem_resp,
	 
	 input hit,
	 input evictreq_out,
	 input [2:0] lru_out,
	 
	 input dirty1_out,
	 input dirty2_out,
	 input dirty3_out,
	 input dirty4_out,
	 
	 input tag1_valid,
	 input tag2_valid,
	 input tag3_valid,
	 input tag4_valid,
	 
	 output logic dirty1_in,
	 output logic dirty2_in,
	 output logic dirty3_in,
	 output logic dirty4_in,
	 
	 output logic ld_way1,
	 output logic ld_way2,
	 output logic ld_way3,
	 output logic ld_way4,
	 
	 output logic ld_valid1,
	 output logic ld_valid2,
	 output logic ld_valid3,
	 output logic ld_valid4,
	 
	 output logic ld_tag1, 
	 output logic ld_tag2,
	 output logic ld_tag3, 
	 output logic ld_tag4,
	 
	 output logic ld_dirty1,
	 output logic ld_dirty2,
	 output logic ld_dirty3,
	 output logic ld_dirty4,
	 
	 output logic ld_lru,
	 output logic ld_hit,
	 output logic ld_evict,
	 output logic ld_evictreq,
	 
	 output logic way1mux_sel,
	 output logic way2mux_sel,
	 output logic way3mux_sel,
	 output logic way4mux_sel,
	 
	 output logic addrmux_sel,
	 output logic wdatamux_sel,
	 output logic [1:0] datamux_sel,
	 output logic [1:0] evictaddrmux_sel,
	 output logic [2:0] readaddrmux_sel,
	 
	 output logic pmem_read,
	 output logic pmem_write,
	 output logic mem_resp
);

enum int unsigned {
    /* List of states */
	 idle,
	 read,
	 read_valid,
	 write_cache,
	 write_mem,
	 resp
} state, next_states;

always_comb
begin : state_actions
	dirty1_in = 1'b0;
	dirty2_in = 1'b0;
	dirty3_in = 1'b0;
	dirty4_in = 1'b0;
	
	ld_way1 = 1'b0;
	ld_way2 = 1'b0;
	ld_way3 = 1'b0;
	ld_way4 = 1'b0;
	
	ld_valid1 = 1'b0;
	ld_valid2 = 1'b0;
	ld_valid3 = 1'b0;
	ld_valid4 = 1'b0;
	
	ld_tag1 = 1'b0;
	ld_tag2 = 1'b0;
	ld_tag3 = 1'b0;
	ld_tag4 = 1'b0;
	
	ld_dirty1 = 1'b0;
	ld_dirty2 = 1'b0;
	ld_dirty3 = 1'b0;
	ld_dirty4 = 1'b0;
	
	ld_lru = 1'b0;
	ld_hit = 1'b0;
	ld_evict = 1'b0;
	ld_evictreq = 1'b0;
	
	way1mux_sel = 1'b0;
	way2mux_sel = 1'b0;
	way3mux_sel = 1'b0;
	way4mux_sel = 1'b0;
	
	addrmux_sel = 1'b0;
	wdatamux_sel = 1'b0;
	
	evictaddrmux_sel = 2'b00;
	datamux_sel = 2'b00;
	
	if (tag2_valid)
		datamux_sel = 2'b01;
	else if (tag3_valid)
		datamux_sel = 2'b10;
	else if (tag4_valid)
		datamux_sel = 2'b11;
	
	readaddrmux_sel = 3'b000;
	
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	mem_resp = 1'b0;
	
	case (state)
		idle: begin
			ld_hit = 1'b1;
		end
	
		write_cache: begin
			if (hit && mem_read) begin
				mem_resp = 1'b1;
				ld_lru = 1'b1;
			end
			
			else if (hit && mem_write) begin
				ld_lru = 1'b1;
				
				if (tag1_valid) begin
					ld_way1 = 1'b1;
					ld_dirty1 = 1'b1;
					dirty1_in = 1'b1;
				end
				
				else if (tag2_valid) begin
					ld_way2 = 1'b1;
					ld_dirty2 = 1'b1;
					dirty2_in = 1'b1;
				end
				
				else if (tag3_valid) begin
					ld_way3 = 1'b1;
					ld_dirty3 = 1'b1;
					dirty3_in = 1'b1;
				end
				
				else begin
					ld_way4 = 1'b1;
					ld_dirty4 = 1'b1;
					dirty4_in = 1'b1;
				end
			end
			
			else if (~hit) begin
				if (lru_out[2:1] == 2'b00) begin
					if (dirty1_out) begin
						ld_evict = 1'b1;
						ld_evictreq = 1'b1;
						ld_dirty1 = 1'b1;
						
						datamux_sel = 2'b00;
						evictaddrmux_sel = 2'b00;
					end
				end
				
				else if (lru_out[2:1] == 2'b01) begin
					if (dirty2_out) begin
						ld_evict = 1'b1;
						ld_evictreq = 1'b1;
						ld_dirty2 = 1'b1;
						
						datamux_sel = 2'b01;
						evictaddrmux_sel = 2'b01;
					end
				end
				
				else if (lru_out[2] == 1 && lru_out[0] == 0) begin
					if (dirty3_out) begin
						ld_evict = 1'b1;
						ld_evictreq = 1'b1;
						ld_dirty3 = 1'b1;
						
						datamux_sel = 2'b10;
						evictaddrmux_sel = 2'b10;
					end
				end
				
				else begin
					if (dirty4_out) begin
						ld_evict = 1'b1;
						ld_evictreq = 1'b1;
						ld_dirty4 = 1'b1;
						
						datamux_sel = 2'b11;
						evictaddrmux_sel = 2'b11;
					end
				end
			end
		end
		
		read: begin
			if (~hit) begin
				if (lru_out[2:1] == 2'b00) begin
					pmem_read = 1'b1;
					way1mux_sel = 1'b1;

					if (pmem_resp) begin
						ld_valid1 = 1'b1;
						ld_tag1 = 1'b1;
						ld_way1 = 1'b1;
					end
				end
				
				else if (lru_out[2:1] == 2'b01) begin
					pmem_read = 1'b1;
					way2mux_sel = 1'b1;
					
					if (pmem_resp) begin
						ld_valid2 = 1'b1;
						ld_tag2 = 1'b1;
						ld_way2 = 1'b1;
					end
				end
				
				else if (lru_out[2] == 1 && lru_out[0] == 0) begin
					pmem_read = 1'b1;
					way3mux_sel = 1'b1;
					
					if (pmem_resp) begin
						ld_valid3 = 1'b1;
						ld_tag3 = 1'b1;
						ld_way3 = 1'b1;
					end
				end
				
				else begin
					pmem_read = 1'b1;
					way4mux_sel = 1'b1;
					
					if (pmem_resp) begin
						ld_valid4 = 1'b1;
						ld_tag4 = 1'b1;
						ld_way4 = 1'b1;
					end
				end
			end
		end
		
		read_valid: begin
			ld_hit = 1'b1;
		end
		
		write_mem: begin			
			pmem_write = 1'b1;
			
			addrmux_sel = 1'b1;
			wdatamux_sel = 1'b1;
			
			if (pmem_resp)
				ld_evictreq = 1'b1;
		end
		
		resp: begin
			mem_resp = 1'b1;
			ld_lru = 1'b1;
			
			if (evictreq_out) begin
				pmem_write = 1'b1;
			
				addrmux_sel = 1'b1;
				wdatamux_sel = 1'b1;
			end
		end
		
		default: ;
	endcase
end

always_comb
begin : next_state_logic
	next_states = state;
	
	case (state) 
		idle: begin
			if (mem_read || mem_write)
				next_states = write_cache;
		end
		
		write_cache: begin
			if (mem_read && hit)
				next_states = idle;
				
			if (mem_read && ~hit)
				next_states = read;
				
			if (mem_write && hit)
				next_states = resp;
				
			if (mem_write && ~hit)
				next_states = read;
		end
				
		read: begin
			if (lru_out[2:1] == 2'b00) begin
				if (pmem_resp) begin
					if (mem_read)
						next_states = read_valid;
					else 
						next_states = idle;
				end
			end
			
			else if (lru_out[2:1] == 2'b01) begin
				if (pmem_resp) begin
					if (mem_read)
						next_states = read_valid;
					else 
						next_states = idle;
				end
			end
			
			else if (lru_out[2] == 1 && lru_out[0] == 0) begin
				if (pmem_resp) begin
					if (mem_read)
						next_states = read_valid;
					else 
						next_states = idle;
				end
			end
			
			else begin
				if (pmem_resp) begin
					if (mem_read)
						next_states = read_valid;
					else 
						next_states = idle;
				end
			end
		end
		
		read_valid: begin
			next_states = resp;
		end
		
		write_mem: begin
			if (pmem_resp) begin
				next_states = idle;
			end
		end
		
		resp: begin
			if (evictreq_out)
				next_states = write_mem;
			else
				next_states = idle;
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