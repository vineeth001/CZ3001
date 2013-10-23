`include "define.v"
module alu(
   A,   //1st operand
   B,   //2nd operand
   op,   //3-bit operation
   imm,   //4-bit immediate operand for shift/rotate
   Out,   //output
   ALU_Status);
   
   input [`DSIZE-1:0] A,B;
   input [3:0] op;
   input [3:0] imm;
   output [`DSIZE-1:0] Out;
   output [2:0] ALU_Status;
   
   reg [`DSIZE-1:0] Out; 
   reg [2*`DSIZE -1:0] tmp;      // for rotate left
   reg [2:0] ALU_Status;         // ALU_Status = [Z,V,N]


always @(A or B or op or imm)
begin
   case(op)
       `ADD: Out = A + B;             
       `SUB: Out = A - B;
       `AND: Out = A & B;
       `OR:  Out = A | B;
       `SLL: Out = A << imm;
       `SRL: Out = A >> imm;
       `SRA: Out = $signed(A) >>> imm;
       `RL:  begin
              tmp = {A, A} << imm;
              Out = tmp[2*`DSIZE -1:`DSIZE];              
             end
       default: Out = 0;   
                  
   endcase
end

////////////// FLAGS  //////////////////////////////////////////////////////
always @(*)
begin
  //Z flag
  if(Out==16'd0 && op[3:2]==2'b00)      //for all arithmetic operations
    ALU_Status[2]=1;
  else if(op[3:2]==2'b00)         //Output is not zero 
    ALU_Status[2]=0;
  else                      //operation is not arithmetic
    ALU_Status[2]=ALU_Status[2];

  //V flag
  if(((A[15]==0 && B[15]==0) && Out[15] && op==4'd0) | ((A[15] && B[15]) && Out[15]==0 && op==4'd1))
    ALU_Status[1]=1;
  else if(op[3:1]==3'd0)
    ALU_Status[1]=0;
  else
    ALU_Status[1]=ALU_Status[1];    
        
  //N flag    
  if(~ALU_Status[1] && op[3:1]==3'd0 && Out[15])  //only for ADD and SUB
    ALU_Status[0]=1;
  else if(op[3:1]==3'd0)                          // either overflow or not negative
    ALU_Status[0]=0;
  else                                       // operation is not ADD or SUB
    ALU_Status[0]=ALU_Status[0];

end
       
endmodule