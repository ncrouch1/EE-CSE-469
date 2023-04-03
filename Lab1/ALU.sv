module ALU(A, B, CTRL, Result, Flags);
	
	// set up
	input logic [31:0] A, B;
	input logic [1:0] CTRL;
	output logic [31:0] Result;
	output logic [3:0] Flags;
	
	logic cout;
	
	// perform
	
	generate
		case(CTRL[0])
		// Add
			1'b0 : begin : add
				ttLogic ttadd (.a(A), .b(B), .sum(Result), .ctrl(CTRL[0]), .cout(cout));
			end
			
			// Sub
			1'b1 : begin : sub
				ttLogic ttsub (.a(A), .b(B), .sum(Result), .ctrl(CTRL[0]), .cout(cout));
			end		
		endcase
	endgenerate
	
	always_comb begin
		case(CTRL)
			// And
			2'b10 : begin : aand
				for (i = 0; i < 32; i++) begin 
					Result[i] = (A[i] & B[i]);
				end
			end
			
			// Or
			2'b11 : begin : orr
				for (i = 0; i < 32; i++) begin 
					Result[i] = (A[i] | B[i]);
				end
			end
		endcase
	end
endmodule
		