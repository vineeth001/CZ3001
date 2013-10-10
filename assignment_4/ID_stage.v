/////////////////////////////////////////////////////////////////////////////////
// Create Date:	16/09/2013
// Module Name: Control 
// Author:	Liwei Yang	
/////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "define.v"

module ID_stage (
  // inputs
  input Clk, Rst,
  input WB_RFWrite_Enab,
  input [`ISIZE-1:0] ID_Inst_in,
  input [`DSIZE-1:0] ID_PCplus1, WB_WriteData,
  input [`RSIZE-1:0] WB_RDest_rd,

  // outputs
  output [`DSIZE-1:0] IF_Alt_PC_out,
  output reg [`DSIZE-1:0] EX_PCplus1,
  output reg [`DSIZE-1:0] EX_ReadData1, EX_ReadData2, EX_SignE_8immed,
  output reg [`RSIZE-1:0] EX_RDest_rd,
  output reg [2:0] EX_ALUOp,
  output IF_PC_Select, 
  output reg EX_MemWrite, EX_MemEnab,
  output reg EX_Mem2Reg, EX_RFileWrite, EX_Sel_ALU_PC1,
  output reg [5:0] EX_src_dest_reg
);


  wire [`RSIZE-1:0] ID_RR1_rd, ID_RR2_rs;
  wire [`DSIZE-1:0] ID_ReadData1_0, ID_ReadData2_0;
  wire [3:0] ID_ALUOp_0;
  wire [`DSIZE-1:0] SignE_8Immed, ZeroE_14Immed;
  wire [`RSIZE-1:0] ID_RDest_rd_0;
  wire [`DSIZE-1:0] ID_nextPC_0, ID_nextPC_1;




  // instantiate Reg_File
  Reg_File EX_1 (
    // inputs
    .Clock(Clk),
    .Reset(Rst),
    .Wen(WB_RFWrite_Enab),
    .RAddr1(ID_RR1_rd),
    .RAddr2(ID_RR2_rs),
    .WAddr(WB_RDest_rd),
    .WData(WB_WriteData),

    // outputs
    .RData1(ID_ReadData1_0),
    .RData2(ID_ReadData2_0)
  );

  // instantiate Control 
  Control EX_3 (
    // inputs
    .Instruction(ID_Inst_in),
    .ReadData1(ID_ReadData1_0),
    .ReadData2(ID_ReadData2_0),
    // outputs
    .Sel_ALUSrc1(Sel_ALUSrc1),
    .Sel_ALUSrc2(Sel_ALUSrc2),
    .Sel_PC_Br_Jmp(Sel_PC_Br_Jmp),
    .Sel_PC_BJ_RF(Sel_PC_BJ_RF),
    .Sel_RF_dest(Sel_RF_dest),
    .Sel_ALU_PC1(Sel_ALU_PC1),
    .IF_PC_Select(IF_PC_Select),
    .ID_MemWrite(ID_MemWrite_0),
    .ID_MemEnab(ID_MemEnab_0),
    .ID_RFileWrite(ID_RFileWrite_0),
    .ID_Mem2Reg(ID_Mem2Reg_0),
    .ID_ALUOp(ID_ALUOp_0)
  );


  // Split up Instruction into required wires (note OPCode and Funct are in Control module
  assign SignE_8Immed = {{8{ID_Inst_in[7]}}, ID_Inst_in[7:0]};		// 16 bit sign extended 8 bit immediate value
  assign ZeroE_14Immed = {2'b0, ID_Inst_in[13:0]};	// 16 bit Zero extended 12 bit immediate value (Displacement)
  // the register signals
  assign ID_RR1_rd = ID_Inst_in[13:11];		// 3 bit Reg file source_1 (address1)
  assign ID_RR2_rs = ID_Inst_in[10:8];			// 3 bit Reg file source_2 (address2)
  
  // Note the RF destination needs to be set to R7 for a jmp
  assign ID_RDest_rd_0 = (Sel_RF_dest)? 4'b1111 : ID_Inst_in[11:8];		// 3 bit Reg file destination (forward to WB stage)
  
  // Muxes to select PC for Branch and Jumps
  assign ID_nextPC_0 = ID_PCplus1 + SignE_8Immed;		// Next PC for branches
  assign ID_nextPC_1 = (Sel_PC_Br_Jmp) ? ZeroE_14Immed : ID_nextPC_0;	// Next PC either Branch OR Jmp
  assign IF_Alt_PC_out = (Sel_PC_BJ_RF) ? ID_ReadData2_0 : ID_nextPC_1;	// Final Alt Next PC, either RegFile2 out OR Branch OR Jmp


  // ID:EX Pipeline register
  always@(posedge Clk)
    if(Rst)
      begin
        EX_PCplus1 <= 16'b0;			// Pass PCplus 1 to EX (and eventually WB stage)
        EX_ReadData1 <= 16'b0;		// RegFile Data 1 out
        EX_ReadData2 <= 16'b0;		// RegFile Data 2 out
        EX_SignE_8immed <= 16'b0;	// Sign extend value to EX stage
        EX_RDest_rd <= 3'b0;			// RegFile write destination forwarded to WB stage (via EX stage0
        EX_ALUOp <= 4'b0;				// ALU operation to EX stage
        EX_MemWrite <= 1'b0;
        EX_MemEnab <= 1'b0;
        EX_Mem2Reg <= 1'b0;
        EX_Sel_ALU_PC1 <= 1'b0;
        EX_RFileWrite <= 1'b0;
        EX_Sel_ALUSrc1 <= 1'b0;
        EX_Sel_ALUSrc2 <= 1'b0;
        EX_src_dest_reg <= 6'b0;
      end
    else
      begin
        EX_PCplus1 <= ID_PCplus1;				// Pass PCplus 1 to EX (and eventually WB stage)	
        EX_ReadData1 <= ID_ReadData1_0;		// RegFile Data 1 out
        EX_ReadData2 <= ID_ReadData2_0;		// RegFile Data 2 out
        EX_SignE_8immed <= SignE_8Immed;		// Sign extend value to EX stage
        EX_RDest_rd <= ID_RDest_rd_0;			// RegFile write destination forwarded to WB stage
        EX_ALUOp <= ID_ALUOp_0;					// ALU operation to EX stage
        EX_Mem2Reg <= ID_Mem2Reg_0;
        EX_Sel_ALU_PC1 <= Sel_ALU_PC1_0;
        EX_RFileWrite <= ID_RFileWrite_0;
        EX_MemWrite <= ID_MemWrite_0;
        EX_MemEnab <= ID_MemEnab_0;
        EX_Sel_ALUSrc1 <= Sel_ALUSrc1;
        EX_Sel_ALUSrc2 <= Sel_ALUSrc2;
        EX_src_dest_reg <= ID_Inst_in[13:8];
      end

endmodule // end of ID_stage module


// Register File module
module Reg_File (
	input Clock,
	input Reset,
	input Wen,
	input [`RSIZE-1:0] RAddr1, 
	input [`RSIZE-1:0] RAddr2, 
	input [`RSIZE-1:0] WAddr, 
	input [`DSIZE-1:0] WData, 

	output [`DSIZE-1:0] RData1,
	output [`DSIZE-1:0] RData2
);

	// register array definition ( 16 registers)
	reg [`DSIZE-1:0] RegFile[0:15];

	always@(posedge Clock or !Reset)
		if(!Reset)
			begin
				RegFile[0]  <= 0;
				RegFile[1]  <= 0;
				RegFile[2]  <= 0;
				RegFile[3]  <= 0;
				RegFile[4]  <= 0;
				RegFile[5]  <= 0;
				RegFile[6]  <= 0;
				RegFile[7]  <= 0;
				RegFile[8]  <= 0;
				RegFile[9]  <= 0;
				RegFile[10]  <= 0;
				RegFile[11]  <= 0;
				RegFile[12]  <= 0;
				RegFile[13]  <= 0;
				RegFile[14]  <= 0;
				RegFile[15]  <= 0;
			end
		else
			RegFile[WAddr] <= ((Wen == 1) && (WAddr != 0)) ? WData : RegFile[WAddr];

	assign RData1 = RegFile[RAddr1];
	assign RData2 = RegFile[RAddr2];

endmodule // end of Reg_File module


// Control module
module Control (
  // inputs
  input	[`ISIZE-1:0] Instruction,
  input	[`DSIZE-1:0] ReadData1, ReadData2,
  
  // outputs
  output reg Sel_ALUSrc1, // Sel for Mux to Src1 of ALU in EX_stage, 1: EX_ReadData1, 0: EX_SignE_8immed
  output reg Sel_ALUSrc2, // Sel for Mux to Src2 of ALU in EX_stage, 1: EX_ReadData2, 0: EX_SignE_8immed
  output reg Sel_PC_Br_Jmp, // Sel for Mux S3 in ID_stage, Next PC or Br/Jmp, 1: ZeroE_14Immed, 0: ID_nextPC_0

  // liwei: need to select between Rd and PCplus1+offset, use S2?
  
  output reg Sel_PC_BJ_RF, // Sel for Mux S2 in ID_stage, i.e. Final Alt Next PC or Br/Jmp, 1: ID_ReadData2_0, 0: ID_nextPC_1
  output reg Sel_RF_dest, // Sel for Mux S4 in ID_stage, 4 bit Reg file destination (forward to WB stage), 1: 4'b1111, 0: ID_Inst_in[11:8]
  output reg Sel_ALU_PC1, // Sel for Mux S7 in Mem_stage, 1: Mem_PCplus1, 0: Mem_ALUResult;
  output reg IF_PC_Select, // Sel for Mux S1 in IF_stage, 1: ID_Alt_PC_in, 0: IF_PCplus1_0 
  output reg ID_MemWrite, // MemWrite to .Write_Enab of Data_mem in Mem_stage, i.e. byte-wide Write Enable(WE), 1: enabled, 0: disabled
  output reg ID_MemEnab, // MemEnab to .Enable of Data_mem in Mem_stage, i.e. EN, 1: enabled, 0: disabled
  output reg ID_RFileWrite, // input back to .WB_RFWrite_Enab in ID_stage, 1: enabled, 0: disabled
  output reg ID_Mem2Reg, // Sel for Mux S8 in Mem_stage, 1: Mem_MemData_out, 0: ALURes_PC1
  output reg Sel_LDimm_MemData, // Sel for Mux S9 in Mem_stage, 1: Mem_LDimm, 0: WB_WriteData0
  output reg [2:0] ID_ALUOp // Opcode for ALU in EX_stage
  );

  // need to add 3-bit FLAG register here
  // bit  |  meaning
  // 2    |  1: zero
  //         0: non-zero
  // 1    |  1: overflow
  //         0: non-overflow
  // 0    |  1: negative
  //         0: non-negative
  reg FLAG[2:0];

  // need a encoding of FLAG for conditions here
  reg COND[2:0];

  always @ *
    begin
      ID_ALUOp = 3'b000;		// initialise default values //(NOP)
      IF_PC_Select = 1'b0;		// S1: def = 0	// def is PC=PC+1
      Sel_PC_BJ_RF = 1'b0;		// S2: def = 0
      Sel_PC_Br_Jmp = 1'b0;	// S3: def = 0
      Sel_RF_dest = 1'b0;		// S4: def = 0
      Sel_ALUSrc1 = 1'b1;		// S5: def = 1	// (RF_Data 1)	
      Sel_ALUSrc2 = 1'b1;		// S6: def = 1	// (RF_Data 2)
      Sel_ALU_PC1 = 1'b0;		// S7: def = 0	// default is ALU result
      ID_Mem2Reg = 1'b0;		// S8: def = 0	
      ID_RFileWrite = 1'b0;	// def = 1
      ID_MemWrite = 1'b0;		// def = 0
      ID_MemEnab = 1'b0;		// def = 0
      
      case(Instruction[15:12])		// The OPCode
      
        `ADD :
	  begin
	    ID_ALUOp = 3'b000;
	    Sel_ALUSrc1 = 1'b1;
	    Sel_ALUSrc2 = 1'b1;
	    // comment out irrelevant signals
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b0;
            Sel_ALU_PC1 = 1'b0;
            IF_PC_Select = 1'b0;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b1;
            ID_Mem2Reg = 1'b0;
	    Sel_LDimm_MemData = 1'b0;


	    ID_ALUOp = ID_Inst_in[14:12];	// ALUOp field is [14:12] of Instruction
	    IF_PC_Select = (ID_Inst_in[7:1] == 7'b1111111) ? 1'b1 : 1'b0;	// S1: JLR & JR: PC <= Rs // Note LSB ignored (covers both instructions)
	    Sel_PC_BJ_RF = (ID_Inst_in[7:1] == 7'b1111111) ? 1'b1 : 1'b0;	// S2: JLR & JR: PC <= Rs // Note LSB ignored (covers both instructions)
	    Sel_ALU_PC1 = (ID_Inst_in[7:0] == 8'b1111_1111) ? 1'b1 : 1'b0;		// S7: JLR Rd = R7
	    //ID_RFileWrite = 1'b1;
	    if(ID_Inst_in[7:0] == 8'b1111_1110)     // JR and NOP have no RF write back // can ignore as both write to R0
	    	ID_RFileWrite = 1'b0;
	    else if(ID_Inst_in[7:0] == 8'b0000_0000)
	    	ID_RFileWrite = 1'b0;
	    else
	    	ID_RFileWrite = 1'b1;
	  end

        `SUB :
	  begin	
	    ID_ALUOp = 3'b001;
	    Sel_ALUSrc1 = 1'b1;
	    Sel_ALUSrc2 = 1'b1;
	    // comment out irrelevant signals
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b0;
            Sel_ALU_PC1 = 1'b0;
            IF_PC_Select = 1'b0;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b1;
            ID_Mem2Reg = 1'b0;
	    Sel_LDimm_MemData = 1'b0;
	  end

        `AND :
	  begin	
	    ID_ALUOp = 3'b010;
	    Sel_ALUSrc1 = 1'b1;
	    Sel_ALUSrc2 = 1'b1;
	    // comment out irrelevant signals
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b0;
            Sel_ALU_PC1 = 1'b0;
            IF_PC_Select = 1'b0;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b1;
            ID_Mem2Reg = 1'b0;
	    Sel_LDimm_MemData = 1'b0;
	  end

        `OR :
	  begin	
	    ID_ALUOp = 3'b011;
	    Sel_ALUSrc1 = 1'b1;
	    Sel_ALUSrc2 = 1'b1;
	    // comment out irrelevant signals
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b0;
            Sel_ALU_PC1 = 1'b0;
            IF_PC_Select = 1'b0;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b1;
            ID_Mem2Reg = 1'b0;
	    Sel_LDimm_MemData = 1'b0;
	  end

        `SLL :
	  begin	
	    ID_ALUOp = 3'b100;
	    Sel_ALUSrc1 = 1'b1;
	    Sel_ALUSrc2 = 1'b0;
	    // comment out irrelevant signals
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b0;
            Sel_ALU_PC1 = 1'b0;
            IF_PC_Select = 1'b0;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b1;
            ID_Mem2Reg = 1'b0;
	    Sel_LDimm_MemData = 1'b0;
	  end

        `SRL :
	  begin	
	    ID_ALUOp = 3'b101;
	    Sel_ALUSrc1 = 1'b1;
	    Sel_ALUSrc2 = 1'b0;
	    // comment out irrelevant signals
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b0;
            Sel_ALU_PC1 = 1'b0;
            IF_PC_Select = 1'b0;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b1;
            ID_Mem2Reg = 1'b0;
	    Sel_LDimm_MemData = 1'b0;
	  end

        `SRA :
	  begin	
	    ID_ALUOp = 3'b110;
	    Sel_ALUSrc1 = 1'b1;
	    Sel_ALUSrc2 = 1'b0;
	    // comment out irrelevant signals
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b0;
            Sel_ALU_PC1 = 1'b0;
            IF_PC_Select = 1'b0;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b1;
            ID_Mem2Reg = 1'b0;
	    Sel_LDimm_MemData = 1'b0;
	  end

        `RL :
	  begin	
	    ID_ALUOp = 3'b111;
	    Sel_ALUSrc1 = 1'b1;
	    Sel_ALUSrc2 = 1'b0;
	    // comment out irrelevant signals
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b0;
            Sel_ALU_PC1 = 1'b0;
            IF_PC_Select = 1'b0;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b1;
            ID_Mem2Reg = 1'b0;
	    Sel_LDimm_MemData = 1'b0;
	  end

        `LW :
	  begin	
	    ID_ALUOp = 3'b000;
	    Sel_ALUSrc1 = 1'b1;
	    Sel_ALUSrc2 = 1'b0;
	    // comment out irrelevant signals
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b0;
            // Sel_ALU_PC1 = 1'b0;
            IF_PC_Select = 1'b0;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b1;
            ID_RFileWrite = 1'b1;
            ID_Mem2Reg = 1'b1;
	    Sel_LDimm_MemData = 1'b0;
	  end

        `SW :
	  begin	
	    ID_ALUOp = 3'b000;
	    Sel_ALUSrc1 = 1'b1;
	    Sel_ALUSrc2 = 1'b0;
	    // comment out irrelevant signals
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b0;
            // Sel_ALU_PC1 = 1'b0;
            IF_PC_Select = 1'b0;
            ID_MemWrite = 1'b1;
            ID_MemEnab = 1'b1;
            ID_RFileWrite = 1'b0;
            // ID_Mem2Reg = 1'b1;
	    Sel_LDimm_MemData = 1'b0;
	  end

        `LHB :
	  begin	
	    // comment out irrelevant signals
	    // ID_ALUOp = 3'bXXX;
	    // Sel_ALUSrc1 = 1'bX;
	    // Sel_ALUSrc2 = 1'bX;
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b0;
            // Sel_ALU_PC1 = 1'b0;
            IF_PC_Select = 1'b0;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b1;
            // ID_Mem2Reg = 1'b1;
	    Sel_LDimm_MemData = 1'b1;
	  end

        `LLB :
	  begin	
	    // comment out irrelevant signals
	    // ID_ALUOp = 3'bXXX;
	    // Sel_ALUSrc1 = 1'bX;
	    // Sel_ALUSrc2 = 1'bX;
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b0;
            // Sel_ALU_PC1 = 1'b0;
            IF_PC_Select = 1'b0;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b1;
            // ID_Mem2Reg = 1'b1;
	    Sel_LDimm_MemData = 1'b1;
	  end

        `B :
	  begin	
	    if(Instruction[10:8] == COND[2:0] or Instruction[10:8] == 3'b111)
	      begin
	        // comment out irrelevant signals
	        // ID_ALUOp = 3'bXXX;
	        // Sel_ALUSrc1 = 1'bX;
	        // Sel_ALUSrc2 = 1'bX;
	        Sel_PC_Br_Jmp = 1'b0;
	        Sel_PC_BJ_RF = 1'b0;
	        // Sel_RF_dest = 1'b0;
                // Sel_ALU_PC1 = 1'b0;
                IF_PC_Select = 1'b1;
                // ID_MemWrite = 1'b0;
                // ID_MemEnab = 1'b0;
                ID_RFileWrite = 1'b0;
                // ID_Mem2Reg = 1'b1;
	        // Sel_LDimm_MemData = 1'b1;
	      end
	    else
	      begin
	        // comment out irrelevant signals
	        // ID_ALUOp = 3'bXXX;
	        // Sel_ALUSrc1 = 1'bX;
	        // Sel_ALUSrc2 = 1'bX;
	        // Sel_PC_Br_Jmp = 1'b0;
	        // Sel_PC_BJ_RF = 1'b0;
	        // Sel_RF_dest = 1'b0;
                // Sel_ALU_PC1 = 1'b0;
                IF_PC_Select = 1'b1;
                ID_MemWrite = 1'b0;
                ID_MemEnab = 1'b0;
                ID_RFileWrite = 1'b0;
                // ID_Mem2Reg = 1'b1;
	        // Sel_LDimm_MemData = 1'b1;
	      end
	  end

        `JAL :
	  begin	
	    // comment out irrelevant signals
	    // ID_ALUOp = 3'bXXX;
	    // Sel_ALUSrc1 = 1'bX;
	    // Sel_ALUSrc2 = 1'bX;
	    Sel_PC_Br_Jmp = 1'b0;
	    Sel_PC_BJ_RF = 1'b0;
	    Sel_RF_dest = 1'b1;
            Sel_ALU_PC1 = 1'b1;
            IF_PC_Select = 1'b1;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b0;
            ID_Mem2Reg = 1'b0;
	    Sel_LDimm_MemData = 1'b0;
	  end

        `JR :
	  begin	
	    // comment out irrelevant signals
	    // ID_ALUOp = 3'bXXX;
	    // Sel_ALUSrc1 = 1'bX;
	    // Sel_ALUSrc2 = 1'bX;
	    // Sel_PC_Br_Jmp = 1'b0;
	    Sel_PC_BJ_RF = 1'b1;
	    Sel_RF_dest = 1'b1;
            // Sel_ALU_PC1 = 1'b1;
            IF_PC_Select = 1'b1;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b0;
            // ID_Mem2Reg = 1'b0;
	    // Sel_LDimm_MemData = 1'b0;
	  end

        `EXEC : // need to add an extra mux for after S4 for next PC
	  begin	
	    // comment out irrelevant signals
	    // ID_ALUOp = 3'bXXX;
	    // Sel_ALUSrc1 = 1'bX;
	    // Sel_ALUSrc2 = 1'bX;
	    // Sel_PC_Br_Jmp = 1'b0;
	    // Sel_PC_BJ_RF = 1'b1;
	    Sel_RF_dest = 1'b0;
            // Sel_ALU_PC1 = 1'b1;
            IF_PC_Select = 1'b1;
            ID_MemWrite = 1'b0;
            ID_MemEnab = 1'b0;
            ID_RFileWrite = 1'b0;
            // ID_Mem2Reg = 1'b0;
	    // Sel_LDimm_MemData = 1'b0;
	  end

	default :
	  begin
	    ;
	  end
      endcase
    end

endmodule		// End of Control module











