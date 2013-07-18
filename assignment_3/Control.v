//control unit for write enable and ALU control

module Control(
  control_input, 
  WriteEn,
  ALUOp
  );
  
  input [3:0] control_input;
  output WriteEn;
  output [2:0] ALUOp;
  
  reg WriteEn;
  reg [2:0] ALUOp;
  
  always@(control_input)
  begin
    WriteEn = control_input[3];
    ALUOp = control_input[2:0];
  end
  
endmodule