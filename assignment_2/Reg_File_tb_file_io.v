// file_io.test
// test file for I/O functions

`include "RF.v"
`timescale 1ns / 10ps
`define EOF 32'hFFFF_FFFF
`define NULL 0
`define MAX_LINE_LENGTH 1000


module Reg_File_tb_file_io;
integer file_input, file_output, file_gold, c, r;
reg [`DSIZE-1:0] RData1_exp, RData2_exp;
reg [8*`MAX_LINE_LENGTH:0] line; /* Line of text read from file */

// instantiate DUT //////////////////////////////////////////////////
// inputs to datapath 
reg clk;
reg rst;
reg wen;
reg [`RSIZE-1:0] RAddr1;
reg [`RSIZE-1:0] RAddr2;
reg [`RSIZE-1:0] WAddr;
reg [`DSIZE-1:0] WData;

wire [`DSIZE-1:0] RData1;
wire [`DSIZE-1:0] RData2;

// instantiate Reg_File
Reg_File Reg_File_inst (
		.Clock(clk),
		.Reset(rst),
		.Wen(wen),
		.RAddr1(RAddr1),
		.RAddr2(RAddr2),
		.WAddr(WAddr),
		.WData(WData),
		
		.RData1(RData1),
		.RData2(RData2)
		);

// generate the clk
always #5 clk = ~clk;

initial
begin
	clk = 0;
	rst = 1;
	wen = 0;
#5	rst = 0;
#10	rst = 1; 
	wen = 1; 
#2	file_input  = $fopen("input.txt","r");
	file_output = $fopen("output.txt","w");
	file_gold   = $fopen("gold.txt","r");

// scan input.txt //////////////////////////////////////////////////
	while (!$feof(file_input))
	begin
		c = $fgetc(file_input);
		// check for comment
		if (c == "/" | c == "#" | c == "%")
			r = $fgets(line, file_input);
		else
		begin
			// Push the character back to the file then read the next time
			r = $ungetc(c, file_input);
			r = $fscanf(file_input, "%h %h %h %h", RAddr1, RAddr2, WAddr, WData);
		end
	#10; // 20ns for each iteration
	end // end of while loop

	$fclose(file_input);
	$fclose(file_gold);
	$fclose(file_output);

#100	$finish;
end	// end of initial

// write to output.txt //////////////////////////////////////////////////

always@(RAddr1 or RAddr2)
begin
	$fwrite(file_output, "%h %h\n", RData1, RData2);
	r = $fscanf(file_gold, "%h %h\n", RData1_exp, RData2_exp);
	if ((RData1 != RData1_exp) | (RData2 != RData2_exp))
		$fdisplay(file_output, "Error: expected: %h %h\n", RData1_exp, RData2_exp);
end

endmodule	// end of datapath_tb_fileio
