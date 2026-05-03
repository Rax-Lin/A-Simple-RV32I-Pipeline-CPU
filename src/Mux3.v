module MUX3#(
    parameter XLEN = 32
)(
    input [XLEN-1:0] in0_i,
    input [XLEN-1:0] in1_i,
    input [XLEN-1:0] in2_i,
    input [1:0] sel_i,
    output reg [XLEN-1:0] out_o
);

always @(*) begin
    if(sel_i == 2'b00)
        out_o = in0_i;
    else if(sel_i == 2'b01)
        out_o = in1_i;
    else
        out_o = in2_i;
end

endmodule