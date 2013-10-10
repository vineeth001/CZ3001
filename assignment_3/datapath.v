// module for Control and Datapath, named as "datapath"

`include "RF.v"
`include "define.v"
`include "alu.v"
`include "Control.v"


module datapath (
	// inputs
	input		  clk,
	input		  rst,
	input  [`ISIZE-1:0] Instruction,
	input  [`DSIZE-1:0] DataInit,
	input		  InitSel,
	// outputs
	output [`DSIZE-1:0] ALUOut
);

// define the wires
wire		WriteEn;
wire [2:0]	ALUOp;
wire [`DSIZE-1:0] RData1;
wire [`DSIZE-1:0] RData2;
wire [`DSIZE-1:0] WData;

assign WData = InitSel ? ALUOut : DataInit;

Control Control_inst (
		.control_input(Instruction[15:12]),
		.ALUOp(ALUOp),
		.WriteEn(WriteEn)
);

alu alu_inst (
		.A(RData1),
		.B(RData2),
		.op(ALUOp),
		.imm(Instruction[3:0]),
		.Out(ALUOut)
);

Reg_File Reg_File_inst (
		.Clock(clk),
		.Reset(rst),
		.Wen(WriteEn),
		.RAddr1(Instruction[7:4]),
		.RAddr2(Instruction[3:0]),
		.WAddr(Instruction[11:8]),
		.WData(WData),

		.RData1(RData1),
		.RData2(RData2)
);

endmodule // end of datapath module

