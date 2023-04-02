module ALU(A, B, CTRL, Result, Flags);
	
	// set up
	input logic [31:0] A, B;
	input logic [1:0] CTRL;
	output logic [31:0] Result;
	output logic [3:0] Flags;
	
	logic cout;
	assign cout = 0;
	
	// perform
	
	always_comb begin
		case(CTRL) 
			// Add
			2'b00 : begin : add
				ttLogic ttadd(.a(A), .b(B), .sum(Result), .ctrl(CTRL[0]), .cout(cout));
			end
			
			
			// Sub
			2'b01 : begin : sub
				ttLogic ttsub(.a(A), .b(B), .sum(Result), .ctrl(CTRL[0]), .cout(cout)); 
			end
			
			// And
			2'b10: begin 
				for (i = 0; i < 2**5; i++) begin
					Result[i] = (A[i] & B[i]);
				end
			end
			
			// Or
			2'b11: begin
				for (i = 0; i < 2**5; i++) begin
					Result[i] = (A[i] | B[i]);
				end
			end
		endcase
	end
endmodule
		