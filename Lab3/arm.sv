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
    input  logic [31:0] ReadDataW,
    output logic [31:0] WriteDataE, 
    output logic [31:0] PCF, ALUResultE,
    output logic        MemWriteD
);

    // datapath buses and signals
    logic [31:0] InstrD, PCPrime, PCPlus4F, PCPlus8D; // pc signals
    logic [ 3:0] RA1D, RA2D;                  // regfile input addresses
    logic [31:0] RD1, RD2;                  // raw regfile outputs
    logic [ 3:0] ALUFlags;                  // alu combinational flag outputs
    logic [31:0] ExtImmE, SrcAE, SrcBE;        // immediate and alu inputs 
    logic [31:0] ResultW;                    // computed or fetched value to be written into regfile or pc
	logic [31:0] ALUOutM, ALUOutW;
    // control signals
    logic BranchD, PCSrcD, MemtoRegD, ALUSrcD, RegWriteD;
	logic BranchE, PCSrcE, MemtoRegE, MemWriteE, ALUSrcE, RegWriteE;
	logic PCSrcM, MemtoRegM, MemWriteM, RegWriteM;
	logic PCSrcW, MemtoRegW, RegWriteW;
	logic [1:0] RegSrcD, ImmSrcD, ALUControlD;
    logic [1:0] RegSrcE, ALUControlE;
	// This signal is true when we need to save the ALU flag outputs
	logic FlagWriteD, FlagWriteE;
	// This is the stored Flags
	logic [3:0] StoredFlags, StoredFlagsE;
	 
	 
	logic [3:0] WA3E, WA3M, WA3W;
	
	// This is 1 when the Condition is true with the flags from the previous clock cycle
	// it is set via the 
	logic CondTrue; // Is 1 when cond is satisfied 
	 	 
	 
    /* The datapath consists of a PC as well as a series of muxes to make decisions about which data words to pass forward and operate on. It is 
    ** noticeably missing the register file and alu, which you will fill in using the modules made in lab 1. To correctly match up signals to the 
    ** ports of the register file and alu take some time to study and understand the logic and flow of the datapath.
    */
    //-------------------------------------------------------------------------------
    //                                      DATAPATH
    //-------------------------------------------------------------------------------

    assign PCPrime = PCSrcD ? ResultW : PCPlus4F;  // mux, use either default or newly computed value
    assign PCPlus4 = PC + 'd4;                  // default value to access next instruction
    assign PCPlus8 = PCPlus4F + 'd4;             // value read when reading from reg[15]

    // update the PC, at rst initialize to 0
    always_ff @(posedge clk) begin
        if (rst) PC <= '0;
        else     PC <= PCPrime;
    end
	 
	always_ff @(posedge clk) begin
	  IntrD <= IntrF;
	end

    // determine the register addresses based on control signals
    // RegSrc[0] is set if doing a branch instruction
    // RefSrc[1] is set when doing memory instructions
    assign RA1D = RegSrcD[0] ? 4'd15        : InstrD[19:16];
    assign RA2D = RegSrcD[1] ? InstrD[15:12] : InstrD[ 3: 0];

    // TODO: insert your reg file here
    // TODO: instantiation comment
    reg_file u_reg_file (
        .clk       (~clk), 
        .wr_en     (RegWriteW),
        .write_data(ResultW),
        .write_addr(WA3W),
        .read_addr1(RA1D), 
        .read_addr2(RA2D),
        .read_data1(RD1), 
        .read_data2(RD2)
    );

    // two muxes, put together into an always_comb for clarity
    // determines which set of instruction bits are used for the immediate
    always_ff @(posedge clk) begin
        if      (ImmSrcD == 'b00) ExtImmE = {{24{InstrD[7]}},InstrD[7:0]};          // 8 bit immediate - reg operations
        else if (ImmSrcD == 'b01) ExtImmE = {20'b0, InstrD[11:0]};                 // 12 bit immediate - mem operations
        else                     ExtImmE = {{6{InstrD[23]}}, InstrD[23:0], 2'b00}; // 24 bit immediate - branch operation
	end
	 
	 

    // WriteData and SrcA are direct outputs of the register file, wheras SrcB is chosen between reg file output and the immediate
    assign WriteData = (RA2 == 'd15) ? PCPlus8D : RD2;           // substitute the 15th regfile register for PC 
    assign SrcA      = (RA1 == 'd15) ? PCPlus8D : RD1;           // substitute the 15th regfile register for PC 
    assign SrcB      = ALUSrc        ? ExtImmE  : WriteDataE;     // determine alu operand to be either from reg file or from immediate

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
    assign Result = MemtoReg ? ReadData : ALUResult;    // determine whether final writeback result is from dmemory or alu


    /* The control conists of a large decoder, which evaluates the top bits of the instruction and produces the control bits 
    ** which become the select bits and write enables of the system. The write enables (RegWrite, MemWrite and PCSrc) are 
    ** especially important because they are representative of your processors current state. 
    */
    //-------------------------------------------------------------------------------
    //                                      CONTROL
    //-------------------------------------------------------------------------------
    
    always_comb begin
        casez (Instr[27:20])

            // ADD (Imm or Reg)
            8'b00?_0100_0 : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we add
                PCSrc    = 0;
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = InstrD[25]; // may use immediate
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00; 
                ALUControl = 'b00;
					 FlagWrite = 1'b0;
            end

            // SUB (Imm or Reg)
            8'b00?_0010_? : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we sub
                PCSrc    = 0; 
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = InstrD[25]; // may use immediate
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00; 
                ALUControl = 'b01;
					 FlagWrite   = Instr[20];
            end

            // AND
            8'b000_0000_0 : begin
                PCSrc    = 0; 
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = 0; 
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00;    // doesn't matter
                ALUControl = 'b10;  
					 FlagWrite = 1'b0;
            end

            // ORR
            8'b000_1100_0 : begin
                PCSrc    = 0; 
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = 0; 
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00;    // doesn't matter
                ALUControl = 'b11;
					 FlagWrite = 1'b0;
            end

            // LDR
            8'b010_1100_1 : begin
                PCSrc    = 0; 
                MemtoReg = 1; 
                MemWrite = 0; 
                ALUSrc   = 1;
                RegWrite = 1;
                RegSrc   = 'b10;    // msb doesn't matter
                ImmSrc   = 'b01; 
                ALUControl = 'b00;  // do an add
					 FlagWrite = 1'b0;
            end

            // STR
            8'b010_1100_0 : begin
                PCSrc    = 0; 
                MemtoReg = 0; // doesn't matter
                MemWrite = 1; 
                ALUSrc   = 1;
                RegWrite = 0;
                RegSrc   = 'b10;    // msb doesn't matter
                ImmSrc   = 'b01; 
                ALUControl = 'b00;  // do an add
					 FlagWrite = 1'b0;
            end

            // B with conditions
            8'b1010_???? : begin
                    PCSrc    = CondTrue; 
                    MemtoReg = 0;
                    MemWrite = 0; 
                    ALUSrc   = 1;
                    RegWrite = CondTrue;
                    RegSrc   = 'b01;
                    ImmSrc   = 'b10; 
                    ALUControl = 'b00;  // do an add
						  FlagWrite = 1'b0;
            end

			default: begin
					PCSrc    = 0; 
                    MemtoReg = 0; // doesn't matter
                    MemWrite = 0; 
                    ALUSrc   = 0;
                    RegWrite = 0;
                    RegSrc   = 'b00;
                    ImmSrc   = 'b00; 
                    ALUControl = 'b00;  // do an add
						  FlagWrite = 1'b0;
			end
        endcase
    end
	 
	// FlagsReg holds our ALU Flags for later use 
	
	// This Module holds the flags for use in the next clock cycle
	FlagsReg flgreg (ALUFlags, FlagWrite, clk, StoredFlags);
	
	always_comb begin // Determine if condition is true via saved ALU Flags
		case (InstrD[31:28]) 
			4'b1110 : CondTrue = 1; // unconditional
			4'b0000 : begin // equal
				CondTrue = StoredFlags[2]; 
			end
			4'b0001 : begin // not equal
				CondTrue = ~StoredFlags[2];
			end
			4'b1010 : begin // greater or equal
				CondTrue = ~StoredFlags[3];
			end
			4'b1100 : begin // greater
				CondTrue = ~StoredFlags[3] & ~StoredFlags[2];
			end
			4'b1101 : begin // less or equal
				CondTrue = StoredFlags[3] | StoredFlags[2];
			end
			4'b1011 : begin // less
				CondTrue = StoredFlags[3];
			end
			default : begin
				CondTrue = 1'b0;
			end
		endcase
	end
	
	

endmodule 