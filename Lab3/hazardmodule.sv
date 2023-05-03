module hazardmodule (
  RA1E, RA2E, WA3M, WA3W,
  StallF, 
  StallD, 
  FlushD, 
  FlushE, 
  ForwardAE, 
  ForwardBE, 
  RegWriteM, 
  RegWriteW, 
  RegWriteE)

input logic [3:0] ra1E, ra2E, wa3M, wa3W;
input logic RegWriteM, RegWriteW, MemtoRegE;
output logic StallF, 
  StallD, 
  FlushD, 
  FlushE, 
  ForwardAE, 
  ForwardBE;

logic Match_M [1:0];
logic Match_W [1:0];

// Data forwarding logic
assign Match_M[0] = (ra1E == wa3M);
assign Match_M[1] = (ra2E == wa3M);
assign Match_W[0] = (ra2E == wa3W);
assign Match_W[1] = (ra2E == wa3W);
always_comb begin
  if(Match_M[0] && RegWriteM) begin
    ForwardAE == 2'b10;
  end else if (Match)
end

endmodule