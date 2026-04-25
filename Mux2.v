module MUX3#(
    parameter XLEN = 32
)(
    input [XLEN-1:0] in0_i,
    input [XLEN-1:0] in1_i,
    input sel_i,
    output reg [XLEN-1:0] out_o
);

always @(*) begin
    if(sel_i == 1'b0)
        out_o = in0_i;
    else
        out_o = in1_i;
end

endmodule