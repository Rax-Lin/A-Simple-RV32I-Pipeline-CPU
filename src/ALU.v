module ALU#(
    parameter XLEN = 32
)(
    input [XLEN-1:0] src1_i,
    input [XLEN-1:0] src2_i,
    input [3:0] alu_control_i,
    output reg [XLEN-1:0] alu_result_o,
    output is_zero_o
);

always @(*) begin
    case(alu_control_i)
        // R-type and I-type operations
        4'b0000: alu_result_o = src1_i & src2_i; // and
        4'b0001: alu_result_o = src1_i | src2_i; // or
        4'b0010: alu_result_o = src1_i + src2_i; // add
        4'b0110: alu_result_o = src1_i - src2_i; // sub
        4'b1001: alu_result_o = src1_i ^ src2_i; // xor
        4'b0011: alu_result_o = src1_i << src2_i[4:0];// sll, slli (logical left shift)
        4'b0100: alu_result_o = src1_i >> src2_i[4:0];// srl, srli (logical right shift)
        4'b1000: alu_result_o = $signed(src1_i) >>> src2_i[4:0];// sra, srai (arithmetic right shift)
        4'b0111: alu_result_o = ($signed(src1_i) < $signed(src2_i)) ? 1 : 0; // slt, slti (set less than)
        4'b0101: alu_result_o = (src1_i < src2_i) ? 1 : 0; // sltu, sltiu (set less than unsigned)
        4'b1111: alu_result_o = 0; // nop , invalid decode
        default : alu_result_o = 0;
    endcase
end

assign is_zero_o = (alu_result_o == 0) ? 1 : 0;

endmodule
