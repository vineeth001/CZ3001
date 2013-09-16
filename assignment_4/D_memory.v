`include "define.v"

module D_memory(
    input [`MEM_SPACE-1:0] address,      // address input
    input [`DSIZE-1:0] data_in,          // data input
    output reg [`DSIZE-1:0] data_out,    // data output
    input clk,
    input write_en
);
    reg [`DSIZE-1:0] memory [0:2**(`MEM_SPACE)-1];

    always @(posedge clk) begin
        if (!write_en) begin            // active-low write enable
            memory[address] <= data_in;
        end
        data_out <= memory[address];
    end

endmodule