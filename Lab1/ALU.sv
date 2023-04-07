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
	
	// start a combination logic block
	always_comb begin
		// open a case statement based on control
			// 2'b00 ADD
			// 2'b01 SUB
			// 2'b10 AND
			// 2'b11 OR
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
	
	
	// start computing flags
	
	
	// Assign the negative flag to the state of the Result bus sign bit
	assign ALUFlags[3] = Result[31];
	
	
	// create a state machine to compute if the result is zero
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
	// Assign the Zero flag to the last state of the zero test
	assign ALUFlags[2] = zeroTest[32];
	
	// Assign the Carryout flag to be the logical and operation
	// between the ALUConrol[0] state and the 32bit chain adders
	// carryout state
		// Abstract: If there was a mathematical operation
		// that resulted in a carryout, raise this flag
	assign ALUFlags[1] = (~ALUControl[1] & cout);
	
	// Assign the Overflow flag to be the logical and of the inverted ALUControl_1, XOR of the A_31 and
	// the sum_31 bits, and the XNOR of the A_31, B_31, and ALUControl_0 bits.
	assign ALUFlags[0] = (~ALUControl[1] & ((a[31] & ~Result[31]) || (~a[31] & Result[31])) &
					((~a[31] & ~b[31] & ~ALUControl[0]) | (a[31] & b[31] & ALUControl[0])));
endmodule

// A module to test the functionality of the ALU shown above, creates a module of the ALU and feeds it
// test cases to ensure that it is working correctly
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
		