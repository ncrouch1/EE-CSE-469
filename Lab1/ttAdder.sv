module ttLogic(a, b, sum, ctrl, cout);
	input logic [31:0] a, b;
	input logic ctrl;
	
	output logic [31:0] sum;
	
	logic [32:0] cry;
	assign cry[0] = ctrl;
	
	genvar i;
	generate begin
		if (ctrl)
		for (i = 0; i < 32; i++) begin
			fullAdder adder(.A(a[i]), .B(b[i]), .cin(cry[i]), .sum(sum[i]), .cout(cry[i+1]));
		end
	endgenerate
	
	assign cout = cry[32];
endmodule
	
	