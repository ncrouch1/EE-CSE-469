// This module implements a 32 bit addition/subtraction circuit
// We use the fullAdder 32 times all linked together, and we 
// use the ctrl bit to control addition vs. subtraction. 
// If the ctrl  bit is 0, we do nothing to inputs, but if it is 1,
// we negate the second input bitwise and set the carryin for the
// first adder to 1, as in two's complement, to get the negative of 
// a number, you bitwise negate and add 1.
module ttLogic(a, b, sum, ctrl, cout);
	input logic [31:0] a, b;
	input logic ctrl;
	
	output logic [31:0] sum;
	output logic cout;
	// carry wires, we set the first carry in to the value of
	// the subtraction control bit. We need to add one to our result
	// if we are doing subtraction, see module comment.
	logic [32:0] cry;
	assign cry[0] = ctrl;
	// make a temporary b that contains either b or its negated version
	// used in addition vs. subtraction.
	logic [31:0] btemp;
	assign btemp = ctrl ? ~b : b;
	// Generate a ton of linked adders, with each carryout leading to the 
	// next carryin bit
	genvar i;
	generate 
		for (i = 0; i < 32; i++) begin : logi
			fullAdder adder(.A(a[i]), .B(btemp[i]), .cin(cry[i]), .sum(sum[i]), .cout(cry[i+1]));
		end
	endgenerate
	// assign the carryout bit.
	assign cout = cry[32];
endmodule

// this module does basic math to test functionality.
module ttLogic_TB();

logic [31:0] a, b;
logic ctrl, cout;
logic [31:0] sum;
	ttLogic dut (a, b, sum, ctrl, cout);

initial begin
	// test basic add/sub
	a = 0;
	b = 1;
	ctrl = 0;
	#10;
	ctrl = 1;
	#10;
	a = 15;
	b = 20;
	#10;
	ctrl = 0;
	#10;
	// test overflow 
	a = 32'b11111111111111111111111111111111;
	b = 1'b1;
	#10;
	ctrl = 1;
	#10;
end

endmodule