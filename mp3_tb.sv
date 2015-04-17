module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

/*
logic clk;
logic mem_resp;
logic mem_read;
logic mem_write;
logic [1:0] mem_byte_enable;
logic [15:0] mem_address;
logic [15:0] mem_rdata;
logic [15:0] mem_wdata;*/

logic clk;
logic pmem_resp;
logic pmem_read;
logic pmem_write;
logic [15:0] pmem_address;
logic [255:0] pmem_rdata;
logic [255:0] pmem_wdata;

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

mp3 dut
(
    .clk,
    .pmem_resp,
    .pmem_rdata,
    .pmem_read,
    .pmem_write,
    .pmem_address,
    .pmem_wdata
);

physical_memory memory
(
    .clk,
    .read(pmem_read),
    .write(pmem_write),
    .address(pmem_address),
    .wdata(pmem_wdata),
    .resp(pmem_resp),
    .rdata(pmem_rdata)
);

endmodule : mp3_tb
