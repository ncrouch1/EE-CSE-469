module ttLogic(a, b, sum, ctrl, cout);
	input logic [31:0] a, b;
	input logic ctrl;
	
	output logic [31:0] sum;
	output logic cout;
	
	logic [32:0] cry;
	assign cry[0] = ctrl;
	
	genvar i;
	generate 
		case(ctrl)
		
			1'b0 : begin : add
				for (i = 0; i < 32; i++) begin : logi
					fullAdder adder(.A(a[i]), .B(b[i]), .cin(cry[i]), .sum(sum[i]), .cout(cry[i+1]));
				end
			end
			
			1'b1 : begin : sub
				for (i = 0; i < 32; i++) begin : logi
					fullAdder adder(.A(a[i]), .B(~b[i]), .cin(cry[i]), .sum(sum[i]), .cout(cry[i+1]));
				end
			end
			
		endcase		
	endgenerate
	
	assign cout = cry[32];
endmodule
	
	