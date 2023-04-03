module ttLogic(a, b, sum, ctrl, cout);
	input logic [31:0] a, b;
	input logic ctrl;
	
	output logic [31:0] sum;
	output logic cout;
	
	logic [32:0] cry;
	assign cry[0] = ctrl;
	
	logic [31:0] btemp;
	assign btemp = ctrl ? b : ~b;
	
	genvar i;
	generate 
		for (i = 0; i < 32; i++) begin : logi
			fullAdder adder(.A(a[i]), .B(btemp[i]), .cin(cry[i]), .sum(sum[i]), .cout(cry[i+1]));
		end
	endgenerate
	
	assign cout = cry[32];
endmodule
	
	