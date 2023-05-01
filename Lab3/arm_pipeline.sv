
module arm_pipeline(
	 input  logic        clk, rst,
    input  logic [31:0] Instr,
    input  logic [31:0] ReadData,
    output logic [31:0] WriteData, 
    output logic [31:0] PC, ALUResult,
    output logic        MemWrite
);

	logic [1:0] AluControlD, AluControlE, ForwardAE, ForwardBE, RegSrcD;
	logic AluSrcD, BranchD, FlagWriteD, ImmSrcD, MemToRegD, MemWriteD, RegWriteD, 
	StallF, StallD, FlushD, FlushE,