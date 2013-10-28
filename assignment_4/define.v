// defines
`define	ISIZE	18
`define	DSIZE	16
`define	RSIZE	4
`define	MEM_SPACE 4

`define ADD 4'b0000
`define SUB 4'b0001
`define AND 4'b0010
`define OR  4'b0011
`define SLL 4'b0100
`define SRL 4'b0101
`define SRA 4'b0110
`define RL  4'b0111
`define LW  4'b1000
`define SW  4'b1001
`define LHB 4'b1010
`define LLB 4'b1011
`define B   4'b1100
`define JAL 4'b1101
`define JR  4'b1110
`define EXEC 4'b1111



//for fileIO
`timescale 1ns / 10ps
`define EOF 32'hFFFF_FFFF
`define NULL 0
`define MAX_LINE_LENGTH 1000




