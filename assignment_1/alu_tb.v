`include "define.v"
module alu_tb;
reg [`DSIZE-1:0] A,B;
reg [2:0] op;
reg [3:0] imm;
wire [`DSIZE-1:0] Out;

alu A0(A,B,op,imm,Out);

initial
begin
    A=`DSIZE'd0; B=`DSIZE'd0; op=3'd0; imm=4'd0;
   #10 A=`DSIZE'd1; B=`DSIZE'd12;
   #10 A=`DSIZE'd51; B=`DSIZE'd12;
   #10 A=`DSIZE'd21; B=`DSIZE'd12; op=3'd1;
   #10 A=`DSIZE'd10; B=`DSIZE'd14; op=3'd1;
   #10 A=`DSIZE'h2E; B=`DSIZE'h16; op=3'd2;
   #10 A=`DSIZE'h34; B=`DSIZE'h26; op=3'd3;
   #10 A=`DSIZE'd10; B=`DSIZE'd14; op=3'd4; imm=4'd4;   
   #10 A=`DSIZE'd11; B=`DSIZE'd14; op=3'd5; imm=4'd3;
   #10 A=`DSIZE'd60; B=`DSIZE'd14; op=3'd6; imm=4'd2;
   #10 A=`DSIZE'd14; B=`DSIZE'd14; op=3'd7; imm=4'd4; 
   #100 $finish;
end

endmodule


