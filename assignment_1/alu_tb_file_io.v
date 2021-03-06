`include "define.v"
module alu_tb_file_io;
reg [`DSIZE-1:0] A,B;
reg [2:0] op;
reg [3:0] imm;
wire [`DSIZE-1:0] Out;
reg [`DSIZE-1:0] exp;
integer file, out, gold, c, r;
real real_time;
reg [8*`MAX_LINE_LENGTH:0] line; /* Line of text read from file */

alu A0(A,B,op,imm,Out);

initial
begin
  A=`DSIZE'd0; B=`DSIZE'd0; op=3'd0; imm=4'd0; 
  file = $fopen("input.txt","r");
  out = $fopen("output.txt","w");
  gold = $fopen("gold.txt","r");

///////////////////////////////////////////--- fetch input ---///////////////////////////////////////////////////////
  while (!$feof(file)) 
  begin
        c = $fgetc(file);
        /* Check the first character for comment */
        if (c == "/" | c == "#" | c == "%")
            r = $fgets(line, file);
        else
            begin
            // Push the character back to the file then read the next time
            r = $ungetc(c, file);
            r = $fscanf(file," %f:\n", real_time);

            // Wait until the abolute time in the file, then read stimulus
            if ($realtime > real_time)
                $fdisplay(out,"Error - absolute time in file is out of order - %t\n",real_time);
            else
                #(real_time - $realtime) r = $fscanf(file," %d %d %d %d\n",A,B,op,imm);
            end

  end // while not EOF
  #10; // so that all output is recorded before closing the files
  $fclose(file);
  $fclose(out);
  #100  $finish;
end // end of initial

///////////////////////////////////////////--- output to output.txt ---/////////////////////////////////////////////////////// 
always@(Out)
 begin
   $fwrite(out,"%h\n",Out);
   r=$fscanf(gold,"%h\n", exp); 
   if(Out !== exp)
     begin
        $fdisplay(out,"%0dns Error: Not matching expected output",$time);  
        $fdisplay(out,"       Got  %h",Out); 
        $fdisplay(out,"       Exp  %h\n",exp);  
     end

 end
endmodule



