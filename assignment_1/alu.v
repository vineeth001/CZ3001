`define SIZE 8
`define ADD 3'b000
`define SUB 3'b001
`define AND 3'b010
`define OR  3'b011
`define SLL 3'b100
`define SRL 3'b101
`define SRA 3'b110
`define RL  3'b111

module alu(
   A,   //`SIZE-bit 1st operand
   B,   //`SIZE-bit 2nd operand
   op,   //3-bit operation
   imm,   //4-bit immeiate operand for shift/rotate
   Out   //`SIZE-bit output
   );
   
   input [`SIZE-1:0] A,B;
   input [2:0] op;
   input [3:0] imm;
   output [`SIZE-1:0] Out;
   
   reg [`SIZE-1:0] Out; 
   reg [2*`SIZE -1:0] tmp;      // for rotate left
      
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
              Out = tmp[2*`SIZE -1:`SIZE];              
             end
       default: Out = 0;              
   endcase
end

endmodule
   
       

   
