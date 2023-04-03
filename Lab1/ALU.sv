module ALU(a, b, ALUControl, Result, ALUFlags);
	
	// set up
	input logic [31:0] a, b;
	input logic [1:0] ALUControl;
	output logic [31:0] Result;
	output logic [3:0] ALUFlags;
	
	logic cout;
	logic sub;
	logic [31:0] orbus, andbus, mathbus;
	assign sub = CTRL[0];
	
	genvar i;
	// perform
	// Math operations driven by the chain of fulladders
	ttLogic addsub (.a(a), .b(b), .sum(mathbus), .ctrl(sub), .cout(cout));

	// logic for and/or
	generate
	for (i = 0; i < 32; i++ ) begin
		andbus[i] = (a[i] & b[i]);
		orbus[i] = (a[i] | b[i]);
	end
	endgenerate
	
	always_comb begin
		case(ALUControl) 
			2'b00 : begin
				Result = mathbus;
			end
			2'b01 : begin
				Result = mathbus;
			end
			2'b10 : begin
				Result = andbus;
			end
			2'b11 : begin
				Result = orbus;
			end
		endcase
	end
	
//	always_comb begin
//		case(CTRL)
//			// And
//			2'b10 : begin : aand
//				for (i = 0; i < 32; i++) begin 
//					Result[i] = (A[i] & B[i]);
//				end
//			end
//			
//			// Or
//			2'b11 : begin : orr
//				for (i = 0; i < 32; i++) begin 
//					Result[i] = (A[i] | B[i]);
//				end
//			end
//		endcase
	end
endmodule
		