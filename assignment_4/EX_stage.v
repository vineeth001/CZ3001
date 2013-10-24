`include "define.v"
module EX_stage (
   input Clk, Rst,
	 input [`DSIZE-1:0] EX_PCplus1,
	 input [`DSIZE-1:0] EX_ReadData1, EX_ReadData2,			
	 input [`DSIZE-1:0] EX_SignE_8immed,
	 input [`RSIZE-1:0] EX_RDest_rd,
	 input [3:0] EX_ALUOp,
	 input EX_MemWrite, EX_MemEnab, 
	 input EX_Sel_ALUSrc1, EX_Sel_ALUSrc2,
	 input EX_Mem2Reg, EX_RFileWrite, EX_Sel_ALU_PC1,
	 
	 input [7:0] EX_src_dest_reg,
	 input [`RSIZE-1:0] EX_mem_RF_Dest,
	 input [`RSIZE-1:0] EX_WB_RF_Dest,
	 input [`DSIZE-1:0] EX_Mem_Result,
	 input [`DSIZE-1:0] EX_WBResult,
	 input WB_RFWrite_Eb,
	 input Mem_RFWrite_Eb,
	 
	 
	 output reg [`DSIZE-1:0] Mem_ALUResult,
	 output reg [`DSIZE-1:0] Mem_PCplus1,
	 output [`DSIZE-1:0] EX_ALUResult_mem,	// this should not be registered (done in BlkRAM)
	 output [`DSIZE-1:0] EX_ReadData2_out,		// this should not be registered (done in BlkRAM)
	 output reg [`RSIZE-1:0] Mem_RDest_rd,
   	 output reg [2:0] ALU_Status,         // status FLAG Z,V,N
	 output EX_MemWrite_out, EX_MemEnab_out, 		// these should not be registered (done in BlkRAM)
	 output reg Mem_Mem2Reg, Mem_RFileWrite, Mem_Sel_ALU_PC1
    );


	wire [`DSIZE-1:0] EX_ALU_Data1_in_stage1,EX_ALU_Data1_in_stage2, EX_ALU_Data2_in_stage1,EX_ALU_Data2_in_stage2, EX_ALUResult_0,ALU_in1, ALU_in2;
	wire [2:0] EX_ALU_Status;
	wire alu_mem_mux1,alu_mem_mux2,alu_wb_mux1,alu_wb_mux2;


	
	// ALU
	ALU EX_2 (
		.A(ALU_in1), 
		.B(ALU_in2),
		.op(EX_ALUOp),
		.imm(EX_SignE_8immed),
		.Out(EX_ALUResult_0),
		.ALU_Status(EX_ALU_Status)
		);
		
	DF_control D1(
	 .DF_src_dest_reg(EX_src_dest_reg),
	 .DF_mem_RF_Dest(EX_mem_RF_Dest),
	 .DF_WB_RF_Dest(EX_WB_RF_Dest),
	 .DF_WB_RFWrite_Eb(WB_RFWrite_Eb),
	 .DF_mem_RFWrite_Eb(Mem_RFWrite_Eb),
	 .alu_in1_mx1(alu_mem_mux1),
	 .alu_in1_mx2(alu_mem_mux2),
	 .alu_in2_mx1(alu_wb_mux1),
	 .alu_in2_mx2(alu_wb_mux2)
	 );
	
	
	
	// Muxes at input of ALU
	// On ReadData 1
	assign EX_ALU_Data1_in_stage1 = (EX_Sel_ALUSrc1) ? EX_ReadData1 : EX_SignE_8immed; 	// Mux to select between RegFile_Data1 and SignE_8immed inputs	
	// On ReadData2 
	assign EX_ALU_Data2_in_stage1 = (EX_Sel_ALUSrc2) ? EX_ReadData2 : EX_SignE_8immed; 	// Mux to select between RegFile_Data2 and SignE_8immed
	//Mux for alu input and alu output forwarding
	assign EX_ALU_Data1_in_stage2 = (alu_mem_mux1) ? EX_Mem_Result : EX_ALU_Data1_in_stage1;
	assign EX_ALU_Data2_in_stage2 = (alu_wb_mux1) ? EX_Mem_Result : EX_ALU_Data2_in_stage1;
	//Final mux at alu input
	assign ALU_in1 = (alu_mem_mux2) ? EX_WBResult : EX_ALU_Data1_in_stage2;
	assign ALU_in2 = (alu_wb_mux2) ? EX_WBResult : EX_ALU_Data2_in_stage2;
	
	
	// Feed through unregistered signals (from ID stage) to WB (Data memory) stage. // these signals are only used by the memory
	assign EX_ReadData2_out = EX_ReadData2;
	assign EX_MemWrite_out = EX_MemWrite;
	assign EX_MemEnab_out = EX_MemEnab;
	assign EX_ALUResult_mem = EX_ALUResult_0;	//(generated in EX stage).
	





// EX:WB Pipeline register
always @ (posedge Clk)
begin
	if (Rst) begin
		Mem_ALUResult <= 16'b0;		// The ALU Result	
		Mem_PCplus1 <= 16'b0;		// RegFile Data 2 out
		Mem_RDest_rd <= 3'b0;			// RegFile write destination forwarded to WB stage
		Mem_Mem2Reg <= 1'b0;
		Mem_RFileWrite <= 1'b0;
		ALU_Status <= 3'b0;
		Mem_Sel_ALU_PC1 <= 1'b0;

		end
	else begin
		Mem_ALUResult <= EX_ALUResult_0;	// The ALU Result
		Mem_PCplus1 <= EX_PCplus1;			// The PC plus 1 value
		Mem_RDest_rd <= EX_RDest_rd;		// RegFile write destination forwarded to WB stage
		Mem_Mem2Reg <= EX_Mem2Reg;
		Mem_RFileWrite <= EX_RFileWrite;
	  	ALU_Status <= EX_ALU_Status;
		Mem_Sel_ALU_PC1 <= EX_Sel_ALU_PC1;
		end
end
endmodule			// End of EX_stage module 



//Data forwarding control
module DF_control(input [7:0] DF_src_dest_reg,
	 input [`RSIZE-1:0] DF_mem_RF_Dest,
	 input [`RSIZE-1:0] DF_WB_RF_Dest,
	 input DF_WB_RFWrite_Eb,
	 input DF_mem_RFWrite_Eb,
	 output alu_in1_mx1,
	 output alu_in1_mx2,
	 output alu_in2_mx1,
	 output alu_in2_mx2 );


//checking for match conditions for data forwarding
	wire result1,result2,result3,result4;
	assign result1 = ~|((DF_mem_RF_Dest ^ DF_src_dest_reg[7:4]));
	assign result2 = ~|((DF_WB_RF_Dest ^ DF_src_dest_reg[7:4]));
	assign result3 = ~|((DF_mem_RF_Dest ^ DF_src_dest_reg[3:0]));
	assign result4 = ~|((DF_WB_RF_Dest ^ DF_src_dest_reg[3:0]));
	
 assign alu_in1_mx1 = DF_mem_RFWrite_Eb & result1;
    
 assign alu_in1_mx2 = DF_WB_RFWrite_Eb & result2;

 assign alu_in2_mx1 = DF_mem_RFWrite_Eb & result3;

 assign alu_in2_mx2 = DF_WB_RFWrite_Eb & result4;

 
endmodule

