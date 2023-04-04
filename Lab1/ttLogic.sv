module ttLogic(a, b, sum, ctrl, cout);
	input logic [31:0] a, b;
	input logic ctrl;
	
	output logic [31:0] sum;
	output logic cout;
	
	logic [32:0] cry;
	assign cry[0] = ctrl;
	
	logic [31:0] btemp;
	assign btemp = ctrl ? ~b : b;
	
	genvar i;
	generate 
		for (i = 0; i < 32; i++) begin : logi
			fullAdder adder(.A(a[i]), .B(btemp[i]), .cin(cry[i]), .sum(sum[i]), .cout(cry[i+1]));
		end
	endgenerate
	
	assign cout = cry[32];
endmodule

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
	
	