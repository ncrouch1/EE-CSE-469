/*
EE / CSE 469
Noah Crouch, Tyler Hittle
Lab 1 Arithmetic Logic Unit

This modules purpose is to perform 4 logical operations
on a pair of 32 bit input buses and output the result of the
logic in another 32 bit output bus. The module also accounts for
any flags which may indicate further information about the result
or status of the result.
*/
module ALU(a, b, ALUControl, Result, ALUFlags);
	
	// set up logic ports
	input logic [31:0] a, b;
	input logic [1:0] ALUControl;
	output logic [31:0] Result;
	output logic [3:0] ALUFlags;
	
	// set up temporary logic
	logic cout;
	logic sub;
	logic [31:0] orbus, andbus, mathbus;
	assign sub = ALUControl[0];
	
	// perform operations
	
	
	
	// Math operations driven by the 32 length chain of fulladders
	ttLogic addsub (.a(a), .b(b), .sum(mathbus), .ctrl(sub), .cout(cout));
	
	// set up for loop var
	genvar i;
	// logic for and/or
	generate
		// perform non mathematical logic tasks such as or, and
		for (i = 0; i < 32; i++ ) begin : Logic
			assign andbus[i] = (a[i] & b[i]);
			assign orbus[i] = (a[i] | b[i]);
		end
	endgenerate
	// Set our result dependent on what result was requested.
	always_comb begin
		// open a case statement based on control
			// 2'b00 ADD
			// 2'b01 SUB
			// 2'b10 AND
			// 2'b11 OR
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
	// assign the test bit to 1 to ensure that 1 & 1 = 1
	assign zeroTest[0] = 1;
	// create for loop var
	genvar j;
	// create a generate block for the for loop
	generate 
		for (j = 0; j < 32; j++) begin : Test_for_zero
			// compute the next state of zeroTest using last state and the
			// jth bit of the result
			assign zeroTest[j+1] = zeroTest[j] & ~Result[j];
		end
	endgenerate
	// the following sets the zero flag
	assign ALUFlags[2] = zeroTest[32];
	// Set the carryout flag
	assign ALUFlags[1] = (~ALUControl[1] & cout);
	// Set the negative flag
	assign ALUFlags[0] = (~ALUControl[1] & ((a[31] & ~Result[31]) || (~a[31] & Result[31])) &
					((~a[31] & ~b[31] & ~ALUControl[0]) | (a[31] & b[31] & ALUControl[0])));
endmodule
// This module runs the ALU through the test cases.
module ALU_testbench();
	// set up logic variables
	logic [31:0] A, B, Result;
	logic [1:0] ALUControl;
	logic [3:0] ALUFlags;
	logic clk;
	logic [103:0] testVectors [16:0];
	
	// Set up clk
	parameter clock_period = 100;
	
	// oscillate clk
	initial clk = 1;
	always begin
		#(clock_period/2);
		clk = ~clk;
	end
	
	// Create module to test
	ALU dut (.a(A), .b(B), .ALUControl(ALUControl), .Result(Result), .ALUFlags(ALUFlags));
		
	// start test cases
	initial begin : Test_cases
		// read in the test vectors
		$readmemh("ALU.tv", testVectors);
		
		// assign the test vectors
		for (int i = 0; i < 16; i = i + 1) begin
			{ALUControl, A, B, Result, ALUFlags} = testVectors[i]; @(posedge clk);
		end
		// end testing
		$stop;
	// end test cases
	end
endmodule
		