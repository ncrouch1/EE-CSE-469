module ALU(A, B, CTRL, Result, Flags);
	
	// set up
	input logic [31:0] A, B;
	input logic [1:0] CTRL;
	output logic [31:0] Result;
	output logic [3:0] Flags;
	
	// perform
	
	always_comb begin
		case(CTRL) 
			// Add
			2'b00: begin
				logic in0, in1, sum, cin, cout;
				cout = 0;
				fullAdder adder(.A(in0), .B(in1), sum, cin, cout);
				for (i = 0; i < 2**5; i++) begin
					cin = cout;
					in0 = A[i];
					in1 = B[i];
					Result[i] = sum;
				end
			end
			
			// Sub
			2'b01: begin 
				logic in0, in1, sum, cin, cout;
				cout = 1;
				fullAdder adder(.A(in0), .B(in1), sum, cin, cout);
				for (i = 0; i < 2**5; i++) begin
					cin = cout;
					in0 = A[i];
					in1 = ~B[i];
					Result[i] = sum;
				end	
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
		