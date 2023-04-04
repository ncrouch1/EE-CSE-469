module ALU(a, b, ALUControl, Result, ALUFlags);
	
	// set up
	input logic [31:0] a, b;
	input logic [1:0] ALUControl;
	output logic [31:0] Result;
	output logic [3:0] ALUFlags;
	
	logic cout;
	logic sub;
	logic [31:0] orbus, andbus, mathbus;
	assign sub = ALUControl[0];
	
	// perform
	// Math operations driven by the chain of fulladders
	ttLogic addsub (.a(a), .b(b), .sum(mathbus), .ctrl(sub), .cout(cout));

	genvar i;
	// logic for and/or
	generate
		for (i = 0; i < 32; i++ ) begin : Logic
			assign andbus[i] = (a[i] & b[i]);
			assign orbus[i] = (a[i] | b[i]);
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
	
	assign ALUFlags[3] = Result[31];
	
	logic[32:0] zeroTest;
	assign zeroTest[0] = 1;
	genvar j;
	generate 
		for (j = 0; j < 32; j++) begin : Test_for_zero
			assign zeroTest[j+1] = zeroTest[j] & ~Result[j];
		end
	endgenerate
	
	assign ALUFlags[2] = zeroTest[32];
	
	assign ALUFlags[1] = (~ALUControl[1] & cout);
	assign ALUFlags[0] = (~ALUControl[1] & ((a[31] & ~Result[31]) || (~a[31] & Result[31])) &
					~(a[31] & b[31] & ALUControl[0]));
endmodule
		