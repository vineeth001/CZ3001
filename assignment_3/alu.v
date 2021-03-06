`include "define.v"
module alu(
   A,   //1st operand
   B,   //2nd operand
   op,   //3-bit operation
   imm,   //4-bit immediate operand for shift/rotate
   Out   //output
   );
   
   input [`DSIZE-1:0] A,B;
   input [2:0] op;
   input [3:0] imm;
   output [`DSIZE-1:0] Out;
   
   reg [`DSIZE-1:0] Out; 
   reg [2*`DSIZE -1:0] tmp;      // for rotate left
      
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

endmodule
   
       

   
