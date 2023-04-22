module FlagsReg ( FlagsIn, FlagW, clk, FlagsOut);
	input logic [3:0] FlagsIn;
	input logic FlagW;
	input logic clk;
	output logic [3:0] FlagsOut;
	
	logic [3:0] memory;
	
	always_ff @(posedge clk) begin
		if(FlagW)
			memory <= FlagsIn;
	end
	assign FlagsOut = memory;
	
endmodule
