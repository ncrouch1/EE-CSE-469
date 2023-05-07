// this module stores 16x32 data with 2 asynch read and 1 synch write ports.
module reg_file(input logic clk, wr_en,
	input logic [31:0] write_data,
	input logic [3:0] write_addr, input logic [3:0]
	read_addr1, read_addr2, output logic [31:0]
	read_data1, read_data2,
	input logic rst);
	// Memory is created below
	logic [31:0] memory [15:0];
	// since reads are asynchronous, we can just use assign here
	assign read_data1 = memory[read_addr1];
	assign read_data2 = memory[read_addr2];
	// on clockedge, we write to the spot if wr_en is high
	genvar i;
	always_ff @(posedge clk) begin
		if (rst) begin
			memory[0] <= '0;
			memory[1] <= '0;
			memory[2] <= '0;
			memory[3] <= '0;
			memory[4] <= '0;
			memory[5] <= '0;
			memory[6] <= '0;
			memory[7] <= '0;
			memory[8] <= '0;
			memory[9] <= '0;
			memory[10] <= '0;
			memory[11] <= '0;
			memory[12] <= '0;
			memory[13] <= '0;
			memory[14] <= '0;
			memory[15] <= '0;
		end else if (wr_en) begin
			memory[write_addr] <= write_data;
		end
	end

endmodule
// test module for regfile
module reg_file_tb ();
logic [31:0] write_data;
logic [3:0] write_addr; 
logic [3:0] read_addr1, read_addr2;
logic [31:0] read_data1, read_data2;
logic clk, wr_en;
// instantiate module to test
reg_file dut (clk, wr_en, write_data, write_addr, read_addr1, read_addr2, read_data1, read_data2);

// this runs our module through a gauntlet, confirming that data is only written when
// wr_en is high when clk goes high, and that the read changes as soon as the address changes 
// for both ports.
initial begin
	clk = 0;
	wr_en = 0;
	write_data = 8675309;
	write_addr = 3;
	read_addr1 = 3;
	#10;
	clk = 1;
	#10;
	clk = 0;
	#5;
	read_addr1 = 2;
	read_addr2 = 3;
	#5;
	clk = 1;
	#10;
	clk = 0;
	wr_en = 1;
	#5;
	read_addr1 = 3;
	read_addr2 = 0;
	#5;
	clk = 0;
	#10;
	clk = 1;
	#10;
	read_addr2 = 3;
	read_addr1 = 2;
	#10;
	clk = 0;
	wr_en = 0;
	write_addr = 4;
	write_data = 420;
	read_addr2 = 4;
	#10;
	clk = 1;
	#10;
	clk = 0;
	wr_en = 1;
	#10;
	clk = 1;
	#10;
end

endmodule
