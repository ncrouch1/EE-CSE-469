/*
 EE / CSE 469
 Noah Crouch, Tyler Hittle
 Full Adder
 04/04/2023
 
 The full adder module below is an implementation of the
 hardware module Full Adder which takes in two one bit inputs and a
 one bit carry in and adds them together resulting in a sum and a carry out
 which is outputted
*/
module fullAdder (A, B, cin, sum, cout);
	
	// set up logic
	input logic A, B, cin;
	output logic sum, cout;
	
	// assign output logic based on inputs
	assign sum = A ^ B ^ cin;
	assign cout = (A&B) | cin & (A^B);
	
endmodule

/*
	This module contains testcases for the above implementation
	of the full adder, there are two implementations included to 
	facilitate test cases
*/
module fullAdder_testBench();
	// Set up test logic
	logic A, B, cin, sum, cout;
	
	// Create a device to test the logic with
	fullAdder dut (A, B, cin, sum, cout);
	
	// Start test cases
	initial begin
		
		// Manually assign test cases
		A = 0; B = 0; cin = 0; #20;
						  cin = 1; #20;
				 B = 1; cin = 0; #20;
						  cin = 1; #20;
		A = 1; B = 0; cin = 0; #20;
						  cin = 1; #20;
				 B = 1; cin = 0; #20;
						  cin = 1; #20;
	// stop test cases
	$stop;
	
	// end testing
	end
	
	// Shorthand
	/*
		initial begin
			for (i = 0; i < 2**3; i++) begin
				(A, B, cin) = i; #20;
			end
		end
	*/
	
endmodule
