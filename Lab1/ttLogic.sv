module ttLogic(a, b, sum, ctrl, cout);
	input logic [31:0] a, b;
	input logic ctrl;
	
	output logic [31:0] sum;
	output logic cout;
	// carry wires, we set the first carry in to the value of
	// the subtraction control bit.
	logic [32:0] cry;
	assign cry[0] = ctrl;
	// make a temporary b that contains either b or its negated version
	logic [31:0] btemp;
	assign btemp = ctrl ? ~b : b;
	// Generate a ton of linked adders
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
	a = 32'b11111111111111111111111111111111;
	b = 1'b1;
	#10;
	ctrl = 1;
	#10;
end

endmodule
	
	