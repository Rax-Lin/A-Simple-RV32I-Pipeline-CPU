module Control_Unit(
    input [6:0] opcode_i, // from instruction decoder
    input [2:0] funct3_i,
    input [6:0] funct7_i,
    output reg_we_o, // to register file
    output is_branch_o, // to exe stage for branch decision
    output is_jal_o,
    output is_jalr_o,
    output reg [2:0] branch_type_o, // see funct3 for branch type
    output reg [3:0] alu_control_o, // to ALU, control the ALU operation
    output reg [1:0] alu_src1_o, // to ALU, control the first operand source: 00 - register, 01 - PC, 10 - zero
    output reg [1:0] alu_src2_o // to ALU, control the second operand source: 00 - register, 01 - immediate, 10 - 4
);
localparam [3:0] ALU_AND  = 4'b0000, ALU_OR   = 4'b0001, ALU_ADD  = 4'b0010, ALU_SLL  = 4'b0011,
                 ALU_SRL  = 4'b0100, ALU_SLTU = 4'b0101, ALU_SUB  = 4'b0110, ALU_SLT  = 4'b0111,
                 ALU_SRA  = 4'b1000, ALU_XOR  = 4'b1001, ALU_NOP  = 4'b1111;


assign reg_we_o = (opcode_i == 7'b0110011) || // R-type
                (opcode_i == 7'b0110111) || // LUI
                (opcode_i == 7'b0010111) || // AUIPC
               (opcode_i == 7'b0010011) || // I-type
               (opcode_i == 7'b0000011) || // load
               (opcode_i == 7'b1101111) || // JAL
               (opcode_i == 7'b1100111);   // JALR

assign is_branch_o = (opcode_i == 7'b1100011); // branch instructions
assign is_jal_o = (opcode_i == 7'b1101111);
assign is_jalr_o = (opcode_i == 7'b1100111);

always @(*) begin
    case(opcode_i)
        7'b0110011 : begin // R-type
            case({funct7_i, funct3_i})
                10'b0000000000 : alu_control_o = ALU_ADD;  // add
                10'b0100000000 : alu_control_o = ALU_SUB;  // sub
                10'b0000000001 : alu_control_o = ALU_SLL;  // sll
                10'b0000000010 : alu_control_o = ALU_SLT;  // slt
                10'b0000000011 : alu_control_o = ALU_SLTU; // sltu
                10'b0000000100 : alu_control_o = ALU_XOR;  // xor
                10'b0000000101 : alu_control_o = ALU_SRL;  // srl
                10'b0100000101 : alu_control_o = ALU_SRA;  // sra
                10'b0000000111 : alu_control_o = ALU_AND;  // and
                10'b0000000110 : alu_control_o = ALU_OR;   // or
                default : alu_control_o = ALU_NOP;
            endcase
            alu_src1_o = 2'b00; // rs1
            alu_src2_o = 2'b00; // rs2
        end
        7'b0010011 : begin // I-type
            case(funct3_i)
                3'b000 : alu_control_o = ALU_ADD;  // addi
                3'b010 : alu_control_o = ALU_SLT;  // slti
                3'b011 : alu_control_o = ALU_SLTU; // sltiu
                3'b100 : alu_control_o = ALU_XOR;  // xori
                3'b110 : alu_control_o = ALU_OR;   // ori
                3'b111 : alu_control_o = ALU_AND;  // andi
                3'b001 : begin
                    if(funct7_i == 7'b0000000) alu_control_o = ALU_SLL; // slli
                    else alu_control_o = ALU_NOP;
                end
                3'b101 : begin
                    if(funct7_i == 7'b0000000) alu_control_o = ALU_SRL; // srli
                    else if(funct7_i == 7'b0100000) alu_control_o = ALU_SRA; // srai
                    else alu_control_o = ALU_NOP;
                end
                default : alu_control_o = ALU_NOP;
            endcase
            alu_src1_o = 2'b00; // rs1
            alu_src2_o = 2'b01; // immediate
        end
        7'b0100011 : begin // store instructions
            alu_src1_o = 2'b00; // rs1
            alu_src2_o = 2'b01; // immediate
            alu_control_o = ALU_ADD; // add (for address calculation)
        end
        7'b0000011 : begin // load instructions
            alu_src1_o = 2'b00; // rs1
            alu_src2_o = 2'b01; // immediate
            alu_control_o = ALU_ADD; // add (for address calculation)
        end
        7'b1100011 : begin // branch instructions
            alu_src1_o = 2'b00; // rs1
            alu_src2_o = 2'b00; // rs2
            alu_control_o = ALU_SUB; // sub (for comparison)
        end
        7'b0110111 : begin // LUI
            alu_src1_o = 2'b10; // zero
            alu_src2_o = 2'b01; // immediate
            alu_control_o = ALU_ADD; // add (for imm << 12)
        end
        7'b0010111 : begin // AUIPC
            alu_src1_o = 2'b01; // PC
            alu_src2_o = 2'b01; // immediate
            alu_control_o = ALU_ADD; // add (for PC + imm << 12)
        end
        7'b1101111 : begin // JAL
            alu_src1_o = 2'b01; // PC
            alu_src2_o = 2'b01; // immediate
            alu_control_o = ALU_ADD; // add (for PC + imm)
        end
        7'b1100111 : begin // JALR
            alu_src1_o = 2'b00; // rs1
            alu_src2_o = 2'b01; // immediate
            alu_control_o = ALU_ADD; // add (for src1 + imm)
        end
        default : begin
            alu_src1_o = 2'b00;
            alu_src2_o = 2'b00;
            alu_control_o = ALU_NOP; // for gatewave debugging, should not happen in real execution
        end
    endcase
end

always @(*)begin
    case(func3_i) 
        3'b000 : branch_type_o = 3'b001; // beq
        3'b001 : branch_type_o = 3'b010; // bne
        3'b100 : branch_type_o = 3'b100; // blt
        3'b101 : branch_type_o = 3'b011; // bge
        3'b110 : branch_type_o = 3'b110; // bltu
        3'b111 : branch_type_o = 3'b101; // bgeu
        default : branch_type_o = 3'b000; // not a branch instruction 
    endcase
end




endmodule
