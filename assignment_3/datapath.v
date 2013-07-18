// module for Control and Datapath, named as "datapath"

`include RF.v
`include define.v
`include alu.v
`include Control.v


module datapath (
	input  [`ISIZE:0] Instruction,
	input  [`DSIZE:0] DataInit,
	input		  InitSel,
	output [`DSIZE:0] ALUOut
);

// define the wires
wire		WriteEn;
wire [2:0]	ALUOp;
wire [`DSIZE:0] RData1;
wire [`DSIZE:0] RData2;
wire [`DSIZE:0] WData;

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

RegFile RegFile_inst (
		.Clock(),
		.Reset(),
		.Wen(WriteEn),
		.Raddr1(Instruction[7:4]),
		.Raddr2(Instruction[3:0]),
		.Waddr(Instruction[11:8]),
		.WData(WData),

		.RData1(RData1),
		.Rdata2(RData2)
);

endmodule // end of datapath module

