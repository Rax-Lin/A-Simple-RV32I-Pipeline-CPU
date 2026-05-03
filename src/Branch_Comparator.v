module Branch_Comparator #(
    parameter XLEN = 32
)(
    input [XLEN-1:0] alu_result_i, // from EX stage
    input alu_is_zero_i, // from EX stage to BPU for branch decision
    input [2:0] branch_type_i, // from control unit for branch decision
    output reg branch_taken_o
);

always @(*) begin
    case(branch_type_i)
        3'b000 : branch_taken_o = alu_is_zero_i; // beq
        3'b001 : branch_taken_o = ~alu_is_zero_i; // bne
        3'b100 : branch_taken_o = ($signed(alu_result_i) < 0); // blt
        3'b101 : branch_taken_o = ($signed(alu_result_i) >= 0); // bge
        3'b110 : branch_taken_o = (alu_result_i < 0); // bltu
        3'b111 : branch_taken_o = (alu_result_i >= 0); // bgeu
        default : branch_taken_o = 0;
    endcase
end


endmodule