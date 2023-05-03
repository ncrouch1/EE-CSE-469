module hazardmodule (
  RA1E, 
  RA2E, 
  WA3M, 
  WA3W, 
  RA1D, 
  RA2D, 
  WA2E,
  PCSrcD, 
  PCSrcE, 
  PCSrcM, 
  PCSrcW,
  RegWriteM, 
  RegWriteW, 
  RegWriteE,
  BranchTakenE,
  StallF, 
  StallD, 
  FlushD, 
  FlushE, 
  ForwardAE, 
  ForwardBE 
  );

input logic [3:0] RA1E, RA2E, WA3M, WA3W;
input logic [3:0] RA1D, RA2D, AW3E;
input logic PCSrcD, PCSrcE, PCSrcM, PCSrcW;
input logic RegWriteM, RegWriteW, MemtoRegE;
input logic BranchTakenE;
output logic StallF, 
  StallD, 
  FlushD, 
  FlushE; 
output logic [1:0] ForwardAE, ForwardBE;

logic Match_M [1:0];
logic Match_W [1:0];

// Data forwarding logic
assign Match_M[0] = (ra1E == wa3M);
assign Match_M[1] = (ra2E == wa3M);
assign Match_W[0] = (ra2E == wa3W);
assign Match_W[1] = (ra2E == wa3W);
always_comb begin

  if(Match_M[0] & RegWriteM) begin
    ForwardAE == 2'b10;
  end 
  else if (Match_W[0] & RegWriteW) begin
    ForwardAE = 2'b01;
  end
  else begin
    ForwardAE = 2'b00;
  end

  if(Match_M[1] & RegWriteM) begin
    ForwardBE == 2'b10;
  end 
  else if (Match_W[1] & RegWriteW) begin
    ForwardBE = 2'b01;
  end 
  else begin
    ForwardBE = 2'b00;
  end
  // end forwarding logic

  //stalling logic
  logic Match_12_D_E;
  logic ldrStallD;
  logic PCWrPendingF;
  assign Match_12_D_E = (ra1D == wa3E) | (ra2D == wa3E);
  assign ldrStallD = Match_12_D_E & MemtoRegE;


  
  assign PCWrPendingF = PCSrcD | PCSrcE | PCSrcM;
  assign StallF = ldrStallD | PCWrPendingF;
  assign FlushD = PCWrPendingF | PCSrcW | BranchTakenE;
  assign FlushE = ldrStallD | BranchTakenE;
  assign StallD = ldrStallD;


end

endmodule