// only support RV32I base instruction set, no extension
module Immediate_Generator#(
    parameter XLEN = 32
)
(
    input [XLEN-1:0] instr_i, // instruction from instruction memory
    output reg [XLEN-1:0] imm_o // immediate value to EX stage
);

localparam [6:0] OPCODE_OP_IMM = 7'b0010011; // I-type ALU
localparam [6:0] OPCODE_LOAD   = 7'b0000011; // I-type load
localparam [6:0] OPCODE_JALR   = 7'b1100111; // I-type jalr
localparam [6:0] OPCODE_STORE  = 7'b0100011; // S-type
localparam [6:0] OPCODE_BRANCH = 7'b1100011; // B-type
localparam [6:0] OPCODE_JAL    = 7'b1101111; // J-type
localparam [6:0] OPCODE_LUI    = 7'b0110111; // U-type
localparam [6:0] OPCODE_AUIPC  = 7'b0010111; // U-type

always @(*) begin
    case (instr_i[6:0])
        OPCODE_OP_IMM,OPCODE_LOAD,OPCODE_JALR: begin
            // I-type immediate: imm[11:0] = instr[31:20]
            imm_o = {{20{instr_i[31]}}, instr_i[31:20]};
        end

        OPCODE_STORE: begin
            // S-type immediate: imm[11:5]=instr[31:25], imm[4:0]=instr[11:7]
            imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
        end

        OPCODE_BRANCH: begin
            // B-type immediate: imm[12|10:5|4:1|11|0] = instr[31|30:25|11:8|7|0]
            imm_o = {{19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        end

        OPCODE_JAL: begin
            // J-type immediate: imm[20|10:1|11|19:12|0] = instr[31|30:21|20|19:12|0]
            imm_o = {{11{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
        end

        OPCODE_LUI,OPCODE_AUIPC: begin
            // U-type immediate: imm[31:12] = instr[31:12], imm[11:0] = 0
            imm_o = {instr_i[31:12], 12'b0};
        end

        default: begin
            imm_o = {XLEN{1'b0}};
        end
    endcase
end

endmodule
