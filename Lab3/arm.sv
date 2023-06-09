/* arm is the spotlight of the show and contains the bulk of the datapath and control logic. This module is split into two parts, the datapath and control. 
*/

// clk - system clock
// rst - system reset
// Instr - incoming 32 bit instruction from imem, contains opcode, condition, addresses and or immediates
// ReadData - data read out of the dmem
// WriteData - data to be written to the dmem
// MemWrite - write enable to allowed WriteData to overwrite an existing dmem word
// PC - the current program count value, goes to imem to fetch instruciton
// ALUResult - result of the ALU operation, sent as address to the dmem

module arm (
    input  logic        clk, rst,
    input  logic [31:0] InstrF,
    input  logic [31:0] ReadDataM,
    output logic [31:0] WriteDataM, 
    output logic [31:0] PCF, ALUOutM,
    output logic        MemWriteM
);

    // datapath buses and signals
    logic [31:0] InstrD, PCPrime, PCPrimePrime, PCPlus4F, PCPlus8D; // pc signals
    logic [ 3:0] RA1D, RA2D, RA1E, RA2E;                  // regfile input addresses
    logic [31:0] RD1D, RD2D, RD1E, RD2E;                  // raw regfile outputs, next regfile
	logic [31:0] RD2EFinal, RD1EFinal;
    logic [ 3:0] ALUFlags;                  // alu combinational flag outputs
    logic [31:0] ExtImmD, ExtImmE, SrcAE, SrcBE;        // immediate and alu inputs 
    logic [31:0] ReadDataW, ResultW;                    // computed or fetched value to be written into regfile or pc
	logic [31:0] ALUResultE, ALUOutW;
	logic [31:0] WriteDataE;
    // control signals
    logic BranchD, PCSrcD, MemToRegD, ALUSrcD, RegWriteD;
	logic BranchE, PCSrcE, MemToRegE, MemWriteE, ALUSrcE, RegWriteE;
	logic PCSrcM, MemToRegM, MemWriteD, RegWriteM;
	logic PCSrcW, MemToRegW, RegWriteW;
	logic [1:0] RegSrcD, ImmSrcD, ALUControlD;
    logic [1:0] RegSrcE, ALUControlE;
	// This signal is true when we need to save the ALU flag outputs
	logic FlagWriteD, FlagWriteE;
	// This is the stored Flags
	logic [3:0] FlagsPrime, FlagsE, CondE;
	// hazard unit output control
    logic StallD, StallF, FlushD, FlushE;
    logic [1:0] ForwardAE, ForwardBE;
	 
	logic [3:0] WA3E, WA3M, WA3W;
	
	// This is 1 when the Condition is true with the flags from the previous clock cycle
	// it is set via the 
	logic CondExE; // Is 1 when cond is satisfied 
	logic BranchTakenE;
	assign BranchTakenE = (CondExE & BranchE);

    hazardmodule hz (RA1D, RA2D, RA1E, RA2E, WA3M, WA3W, WA3E, PCSrcD, PCSrcE, PCSrcM, PCSrcW, RegWriteM,
        RegWriteW, RegWriteE, MemToRegE, BranchTakenE, StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE);
	 
    /* The datapath consists of a PC as well as a series of muxes to make decisions about which data words to pass forward and operate on. It is 
    ** noticeably missing the register file and alu, which you will fill in using the modules made in lab 1. To correctly match up signals to the 
    ** ports of the register file and alu take some time to study and understand the logic and flow of the datapath.
    */
    //-------------------------------------------------------------------------------
    //                                      DATAPATH
    //-------------------------------------------------------------------------------
    assign PCPrimePrime = PCSrcW ? ResultW : PCPlus4F;  // mux, use either default or newly computed value
    assign PCPrime = BranchTakenE ? ALUResultE : PCPrimePrime;
    assign PCPlus4F = PCF + 'd4;                  // default value to access next instruction
    assign PCPlus8D = PCPlus4F;             // value read when reading from reg[15]

    // update the PC, at rst initialize to 0
    // Register F 
    always_ff @(posedge clk) begin
        if (rst) begin 
			   PCF <= 0;
		  end else if (StallF) begin 
            PCF <= PCF; 
		  end else begin
            PCF <= PCPrime;
			end
    end
	
    // Register D
	always_ff @(posedge clk) begin
        if (FlushD) begin 
            InstrD <= '0;
        end else if (StallD) begin
            InstrD <= InstrD;
        end else begin
            InstrD <= InstrF;
        end
	end

    // determine the register addresses based on control signals
    // RegSrc[0] is set if doing a branch instruction
    // RefSrc[1] is set when doing memory instructions
    assign RA1D = RegSrcD[0] ? 4'd15        : InstrD[19:16];
    assign RA2D = RegSrcD[1] ? InstrD[15:12] : InstrD[ 3: 0];

    // TODO: insert your reg file here
    // TODO: instantiation comment
    reg_file u_reg_file (
        .clk       (clk), 
        .wr_en     (RegWriteW),
        .write_data(ResultW),
        .write_addr(WA3W),
        .read_addr1(RA1D), 
        .read_addr2(RA2D),
        .read_data1(RD1D), 
        .read_data2(RD2D),
		  .rst(rst)
    );

    // two muxes, put together into an always_comb for clarity
    // determines which set of instruction bits are used for the immediate
    always_comb begin
    if      (ImmSrcD == 'b00 | ImmSrcD == 'b01) begin
			if (ImmSrcD == 'b00) begin  // 8 bit immediate - reg operations
				ExtImmD = {{24{InstrD[7]}},InstrD[7:0]};
			end else begin // 12 bit immediate - mem operations
				ExtImmD = {20'b0, InstrD[11:0]}; 
			end
		end else begin
			ExtImmD = {{6{InstrD[23]}}, InstrD[23:0], 2'b00}; // 24 bit immediate - branch operation
		end
    end
    // E Register
    always_ff @(posedge clk) begin
        if (FlushE) begin 
            ExtImmE = '0;
            WA3E <= '0;
            PCSrcE <= '0;
            RA1E <= '0;
            RA2E <= '0;
				RD1E <= '0;
				RD2E <= '0;
            MemToRegE <= '0;
            MemWriteE <= '0;
            RegWriteE <= '0;
            BranchE <= '0;
            ALUControlE <= '0;
            ALUSrcE <= '0;
            FlagsE <= '0;
            FlagWriteE <= '0;
            CondE <= '0;
        end 
		  else begin
            WA3E <= InstrD[15:12];
            PCSrcE <= PCSrcD;
            RA1E <= RA1D;
            RA2E <= RA2D;
				RD1E <= RD1D;
				RD2E <= RD2D;
            MemToRegE <= MemToRegD;
            MemWriteE <= MemWriteD;
            RegWriteE <= RegWriteD;
            BranchE <= BranchD;
            ALUControlE <= ALUControlD;
            ALUSrcE <= ALUSrcD;
            //FlagsE <= FlagsPrime;
				FlagsE <= FlagWriteE ? ALUFlags : FlagsE;
				FlagWriteE <= FlagWriteD;
            CondE <= InstrD[31:28];
				ExtImmE <= ExtImmD;
        end
    end
	
	 

    // WriteData and SrcA are direct outputs of the register file, wheras SrcB is chosen between reg file output and the immediate
    assign RD2EFinal = (RA2E == 'd15) ? PCPlus8D : RD2E;           // substitute the 15th regfile register for PC
	 assign RD1EFinal = (RA1E == 'd15) ? PCPlus8D : RD1E;
	 
	logic [31:0] SrcBEPrime;

    Mux2x1 alusrc1 (.RegisterData(RD1EFinal), .Result(ResultW), .ALUOut(ALUOutM), .forward(ForwardAE), .ALUSrc(SrcAE));
	Mux2x1 alusrc2 (.RegisterData(RD2EFinal), .Result(ResultW), .ALUOut(ALUOutM), .forward(ForwardBE), .ALUSrc(WriteDataE));
	assign SrcBE = ALUSrcE ? ExtImmE : WriteDataE;
	
	 
    // TODO: insert your alu here
    // TODO: instantiation comment
    ALU u_alu (
        .a          (SrcAE), 
        .b          (SrcBE),
        .ALUControl (ALUControlE),
        .Result     (ALUResultE),
        .ALUFlags   (ALUFlags)
    );

    // determine the result to run back to PC or the register file based on whether we used a memory instruction
    assign ResultW = MemToRegW ? ReadDataW : ALUOutW;    // determine whether final writeback result is from dmemory or alu
    
    // M register
    always_ff @(posedge clk) begin
        WA3M <= WA3E;
        PCSrcM <= CondExE & PCSrcE;
        RegWriteM <= CondExE & RegWriteE;
        MemWriteM <= CondExE & MemWriteE;
        MemToRegM <= MemToRegE;
		  ALUOutM <= ALUResultE;
		  WriteDataM <= WriteDataE;
    end
    
    // writeback reg
    always_ff @(posedge clk) begin
        WA3W <= WA3M;
        PCSrcW <= PCSrcM;
        RegWriteW <= RegWriteM;
        MemToRegW <= MemToRegM;
        ALUOutW <= ALUOutM;
        ReadDataW <= ReadDataM;
    end

    /* The control conists of a large decoder, which evaluates the top bits of the instruction and produces the control bits 
    ** which become the select bits and write enables of the system. The write enables (RegWrite, MemWrite and PCSrc) are 
    ** especially important because they are representative of your processors current state. 
    */
    //-------------------------------------------------------------------------------
    //                                      CONTROL
    //-------------------------------------------------------------------------------
    
    always_comb begin
        casez (InstrD[27:20])

            // ADD (Imm or Reg)
            8'b00?_0100_0 : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we add
                PCSrcD    = 0;
                MemToRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = InstrD[25]; // may use immediate
                RegWriteD = 1;
					 BranchD   = 0;
                RegSrcD   = 'b00;
                ImmSrcD   = 'b00; 
                ALUControlD = 'b00;
				    FlagWriteD = 1'b0;
            end

            // SUB (Imm or Reg)
            8'b00?_0010_? : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we sub
                PCSrcD    = 0; 
                MemToRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = InstrD[25]; // may use immediate
                RegWriteD = 1;
					 BranchD   = 0;
		   		 RegSrcD   = 'b00;
                ImmSrcD   = 'b00; 
                ALUControlD = 'b01;
			       FlagWriteD   = InstrD[20];
            end

            // AND
            8'b000_0000_0 : begin
                PCSrcD    = 0; 
                MemToRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = 0; 
                RegWriteD = 1;
					 BranchD   = 0;
					 RegSrcD   = 'b00;
                ImmSrcD   = 'b00;    // doesn't matter
                ALUControlD = 'b10;  
				    FlagWriteD = 1'b0;
            end

            // ORR
            8'b000_1100_0 : begin
                PCSrcD    = 0; 
                MemToRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = 0; 
                RegWriteD = 1;
					 BranchD   = 0;
					 RegSrcD   = 'b00;
                ImmSrcD   = 'b00;    // doesn't matter
                ALUControlD = 'b11;
				    FlagWriteD = 1'b0;
            end

            // LDR
            8'b010_1100_1 : begin
                PCSrcD    = 0; 
                MemToRegD = 1; 
                MemWriteD = 0; 
                ALUSrcD   = 1;
                RegWriteD = 1;
					 BranchD   = 0;
					 RegSrcD   = 'b10;    // msb doesn't matter
                ImmSrcD   = 'b01; 
                ALUControlD = 'b00;  // do an add
				    FlagWriteD = 1'b0;
            end

            // STR
            8'b010_1100_0 : begin
                PCSrcD    = 0; 
                MemToRegD = 0; // doesn't matter
                MemWriteD = 1; 
                ALUSrcD   = 1;
                RegWriteD = 0;
  				    BranchD   = 0;
					 RegSrcD   = 'b10;    // msb doesn't matter
                ImmSrcD   = 'b01; 
                ALUControlD = 'b00;  // do an add
				    FlagWriteD = 1'b0;
            end

            // B with conditions
            8'b1010_???? : begin
                    PCSrcD    = 1; 
                    MemToRegD = 0;
                    MemWriteD = 0; 
                    ALUSrcD   = 1;
						  BranchD 	= 1;
                    RegWriteD = 1;
                    RegSrcD   = 'b01;
                    ImmSrcD   = 'b10; 
                    ALUControlD = 'b00;  // do an add
					     FlagWriteD = 1'b0;
            end

			default: begin
					PCSrcD    = 0; 
				   MemToRegD = 0; // doesn't matter
				   MemWriteD = 0; 
				   ALUSrcD   = 0;
				   RegWriteD = 0;
				   BranchD 	= 0;
				   RegSrcD   = 'b00;
			  	   ImmSrcD   = 'b00; 
				   ALUControlD = 'b00;  // do an add
				   FlagWriteD = 1'b0;
			end
        endcase
    end
	 
	// FlagsReg holds our ALU Flags for later use 
	
	// This Module holds the flags for use in the next clock cycle
	//FlagsReg flgreg (ALUFlags, FlagWriteE, clk, FlagsE);

	
	always_comb begin // Determine if condition is true via saved ALU Flags
		case (CondE) 
			4'b1110 : CondExE = 1; // unconditional
			4'b0000 : begin // equal
				CondExE = FlagsE[2]; 
			end
			4'b0001 : begin // not equal
				CondExE = ~FlagsE[2];
			end
			4'b1010 : begin // greater or equal
				CondExE = ~FlagsE[3];
			end
			4'b1100 : begin // greater
				CondExE = ~FlagsE[3] & ~FlagsE[2];
			end
			4'b1101 : begin // less or equal
				CondExE = FlagsE[3] | FlagsE[2];
			end
			4'b1011 : begin // less
				CondExE = FlagsE[3];
			end
			default : begin
				CondExE = 1'b0;
			end
		endcase
	end
	
	

endmodule 