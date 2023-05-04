module Mux2x1(input logic [31:0] RegisterData, Result, ALUOut, input logic [1:0] forward, output logic[31:0] ALUSrc);

	always_comb begin
		if (~forward[0] & ~forward[1])
			ALUSrc <= RegisterData;
		else if (forward[0] & ~forward[1])
			ALUSrc <= Result;
		else 
			ALUSrc <= ALUOut;
	end 
	
endmodule 