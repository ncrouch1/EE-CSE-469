module reg_file(input logic clk, wr_en,
	input logic [31:0] write_data,
	input logic [3:0] write_addr, input logic [3:0]
	read_addr1, read_addr2, output logic [31:0]
	read_data1, read_data2);
	// Memory is created below
	logic [15:0][31:0] memory;
	// since reads are asynchronous, we can just use assign here
	assign read_data1 = memory[read_addr1];
	assign read_data2 = memory[read_addr2];
	// on clockedge, we write to the spot if wr_en is high
	always_ff @(posedge clk) begin
		if (wr_en) begin
			memory[write_addr] <= write_data;
		end
	end

endmodule

module reg_file_tb ();
logic [31:0] write_data;
logic [3:0] write_addr; 
logic [3:0] read_addr1, read_addr2;
logic [31:0] read_data1, read_data2;
logic clk, wr_en;

reg_file dut (clk, wr_en, write_data, write_addr, read_addr1, read_addr2, read_data1, read_data2);


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
