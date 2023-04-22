/* This module holds our flags in dedicated memory to facilitate
	conditional jumps.
	FlagsIn is our flags input
	clk is the clock signal
	FlagW tells the circuit when to update the flag registers
	FlagsOut outputs the currently saved flags.
*/
module FlagsReg ( FlagsIn, FlagW, clk, FlagsOut);
	input logic [3:0] FlagsIn;
	input logic FlagW;
	input logic clk;
	output logic [3:0] FlagsOut;
	
	logic [3:0] memory;
	// On clock edge, update the saved flags if we are told to 
	// write flags.
	always_ff @(posedge clk) begin
		if(FlagW)
			memory <= FlagsIn;
	end
	assign FlagsOut = memory;
	
endmodule
