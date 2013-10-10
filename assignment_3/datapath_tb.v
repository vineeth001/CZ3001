// testbench for datapath module
`include "define.v"
`include "datapath.v"
`timescale 1ns / 100ps

module datapath_tb ();
// inputs to datapath 
reg clk;
reg rst;
reg [`ISIZE-1:0] Instruction;
reg 		 InitSel;
reg [`DSIZE-1:0] DataInit;

// outputs to datapath
wire [`DSIZE-1:0] ALUOut;

datapath datapath_inst (
		.clk(clk),
		.rst(rst),
		.Instruction(Instruction),
		.InitSel(InitSel),
		.DataInit(DataInit),

		.ALUOut(ALUOut)
		);

always #5 clk = ~clk;

integer i;
initial
begin
	clk = 0;
	rst = 1;
#5	rst = 0;
#10	rst = 1; InitSel = 0;


// write to RF
for (i=0; i<16; i=i+1)
begin
#2	Instruction = 16'b1000_0000_0000_0000 + (i<<8);
	DataInit = i+16;
#18	$display("Writing: WAddr=%h, WData=%h\n",i ,i+16);
end
	InitSel = 1;

// verify alu
for (i=0; i<8; i=i+1)
begin
#2	Instruction = 16'b1000_0000_0010_0001 + (i<<12) +((i+3)<<8);
#18	$display("Instruction = %h\nALU output: %h\n\n",Instruction, ALUOut);
end

#1000	$finish;

end

endmodule // end of RF_tb
