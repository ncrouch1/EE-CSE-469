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
	// Set our result dependent on what result was requested.
	always_comb begin
		case(ALUControl) 
			2'b00 : begin // Add
				Result = mathbus;
			end
			2'b01 : begin // Subtract
				Result = mathbus;
			end
			2'b10 : begin // And
				Result = andbus;
			end
			2'b11 : begin // Or
				Result = orbus;
			end
		endcase
	end
	// set flags!
	assign ALUFlags[3] = Result[31];
	// We check to see if the result is zero
	logic[32:0] zeroTest;
	assign zeroTest[0] = 1;
	genvar j;
	generate 
		for (j = 0; j < 32; j++) begin : Test_for_zero
			assign zeroTest[j+1] = zeroTest[j] & ~Result[j];
		end
	endgenerate
	// the following sets the zero flag
	assign ALUFlags[2] = zeroTest[32];
	// Set the carryout flag
	assign ALUFlags[1] = (~ALUControl[1] & cout);
	// Set the negative flag
	assign ALUFlags[0] = (~ALUControl[1] & ((a[31] & ~Result[31]) || (~a[31] & Result[31])) &
					~(a[31] & b[31] & ALUControl[0]));
endmodule
// This module runs the ALU through the test cases.
module ALU_testbench();
	logic [31:0] A, B, Result;
	logic [1:0] ALUControl;
	logic [3:0] ALUFlags;
	
	
	ALU dut (.a(A), .b(B), .ALUControl(ALUControl), .Result(Result), .ALUFlags(ALUFlags));
		
	initial begin : Test_cases
		// ADD 0, 0
		A = 32'h00000000; B = 32'h00000000; ALUControl = 2'b00; #10;
		// ADD 0, -1
								B = 32'hFFFFFFFF; 						  #10;
		// ADD 1, -1
		A = 32'h00000001; B = 32'hFFFFFFFF; 						  #10;
		// ADD FF, 1
		A = 32'h000000FF; B = 32'h00000001; 						  #10;
		// SUB 0, 0
		A = 32'h00000000; B = 32'h00000000; ALUControl = 2'b01; #10;
		// SUB 0, -1
		A = 32'h00000000; B = 32'hFFFFFFFF; 						  #10;
		// SUB 1, 1
		A = 32'h00000001; B = 32'h00000001; 						  #10;
		// AND FFFFFFFF, FFFFFFFF
		A = 32'hFFFFFFFF; B = 32'hFFFFFFFF; ALUControl = 2'b10; #10;
		// AND FFFFFFFF, 12345678
								B = 32'h12345678;							  #10;
		// AND 00000000, FFFFFFFF
		A = 32'h00000000; B = 32'hFFFFFFFF;							  #10;
		// OR FFFFFFFF, FFFFFFFF
		A = 32'hFFFFFFFF; B = 32'hFFFFFFFF; ALUControl = 2'b11; #10;
		// OR 12345678, 87654321
		A = 32'h12345678; B = 32'h87654321; 						  #10;
		// OR 00000000, FFFFFFFF
		A = 32'h00000000; B = 32'hFFFFFFFF;							  #10;
		// OR 00000000, 00000000
								B = 32'h00000000;							  #10;
	
	end
endmodule
		