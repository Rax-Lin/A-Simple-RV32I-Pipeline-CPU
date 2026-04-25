module Adder#(
    parameter XLEN = 32
)
(
    input [XLEN-1:0] src1_i,
    input [XLEN-1:0] src2_i,
    output [XLEN-1:0] sum_o
);

assign sum_o = src1_i + src2_i;

endmodule