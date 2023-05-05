module hazardmodule (
  RA1D, 
  RA2D, 
  RA1E,
  RA2E,
  WA3M, 
  WA3W,
  WA3E, 
  PCSrcD, 
  PCSrcE, 
  PCSrcM, 
  PCSrcW,
  RegWriteM, 
  RegWriteW, 
  RegWriteE,
  MemToRegE,
  BranchTakenE,
  StallF, 
  StallD, 
  FlushD, 
  FlushE, 
  ForwardAE, 
  ForwardBE 
  );

input logic [3:0] WA3M, WA3W;
input logic [3:0] RA1D, RA2D, RA1E, RA2E, WA3E;
input logic PCSrcD, PCSrcE, PCSrcM, PCSrcW;
input logic RegWriteM, RegWriteE, RegWriteW, MemToRegE;
input logic BranchTakenE;
output logic StallF, 
  StallD, 
  FlushD, 
  FlushE; 
output logic [1:0] ForwardAE, ForwardBE;

logic Match_M [1:0];
logic Match_W [1:0];

// Data forwarding logic
assign Match_M[0] = (RA1E == WA3M);
assign Match_M[1] = (RA1E == WA3M);
assign Match_W[0] = (RA2E == WA3W);
assign Match_W[1] = (RA2E == WA3W);
always_comb begin

  if(Match_M[0] & RegWriteM) begin
    ForwardAE = 2'b10;
  end 
  else if (Match_W[0] & RegWriteW) begin
    ForwardAE = 2'b01;
  end
  else begin
    ForwardAE = 2'b00;
  end

  if(Match_M[1] & RegWriteM) begin
    ForwardBE = 2'b10;
  end 
  else if (Match_W[1] & RegWriteW) begin
    ForwardBE = 2'b01;
  end 
  else begin
    ForwardBE = 2'b00;
  end
  // end forwarding logic
end
  //stalling logic
  logic Match_12_D_E;
  logic ldrStallD;
  logic PCWrPendingF;
  assign Match_12_D_E = (RA1D == WA3E) | (RA2D == WA3E);
  assign ldrStallD = Match_12_D_E & MemToRegE;


  
  assign PCWrPendingF = PCSrcD | PCSrcE | PCSrcM;
  assign StallF = ldrStallD | PCWrPendingF;
  assign FlushD = PCWrPendingF | PCSrcW | BranchTakenE;
  assign FlushE = ldrStallD | BranchTakenE;
  assign StallD = ldrStallD;


endmodule 