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

input logic [3:0] RA1E, RA2E, WA3M, WA3W;
input logic RegWriteM, RegWriteW, MemtoRegE;
output logic StallF, 
  StallD, 
  FlushD, 
  FlushE, 
  ForwardAE, 
  ForwardBE;

always_comb begin
  
end

endmodule