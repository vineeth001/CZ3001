`define SIZE 6

module alu_tb;
reg [`SIZE-1:0] A,B;
reg [2:0] op;
reg [3:0] imm;
wire [`SIZE-1:0] Out;

alu A0(A,B,op,imm,Out);

initial
begin
    A=`SIZE'd0; B=`SIZE'd0; op=3'd0; imm=4'd0;
   #10 A=`SIZE'd1; B=`SIZE'd12;
   #10 A=`SIZE'd51; B=`SIZE'd12;
   #10 A=`SIZE'd21; B=`SIZE'd12; op=3'd1;
   #10 A=`SIZE'd10; B=`SIZE'd14; op=3'd1;
   #10 A=`SIZE'h2E; B=`SIZE'h16; op=3'd2;
   #10 A=`SIZE'h34; B=`SIZE'h26; op=3'd3;
   #10 A=`SIZE'd10; B=`SIZE'd14; op=3'd4; imm=4'd4;   
   #10 A=`SIZE'd11; B=`SIZE'd14; op=3'd5; imm=4'd3;
   #10 A=`SIZE'd60; B=`SIZE'd14; op=3'd6; imm=4'd2;
   #10 A=`SIZE'd14; B=`SIZE'd14; op=3'd7; imm=4'd4; 
   #100 $finish;
end

endmodule


