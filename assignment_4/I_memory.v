`include "define.v"

module I_memory(
    input [`MEM_SPACE-1:0] address,      // address input
    output reg [`ISIZE-1:0] data_out,    // data output
    input clk
);
    reg [`ISIZE-1:0] memory [0:2**(`MEM_SPACE-1)];

    always @(posedge clk) begin
        data_out <= memory[address];
    end

endmodule