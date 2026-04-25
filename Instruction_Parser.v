// only support RV32I base instruction set, without any extension.
module Instruction_Parser#(
    parameter XLEN = 32
)
(
    input [XLEN-1:0] instr_i, // from instruction memory
    output [6:0] opcode_o, // to control unit
    output [4:0] rs1_o, // to register file
    output [4:0] rs2_o, // to register file
    output [4:0] rd_o, // to register file
    output [2:0] funct3_o, // to ALU
    output [6:0] funct7_o // to ALU
);

assign opcode_o = instr_i[6:0];
assign rs1_o = instr_i[19:15];
assign rs2_o = instr_i[24:20];
assign rd_o = instr_i[11:7];   
assign funct3_o = instr_i[14:12];
assign funct7_o = instr_i[31:25];

endmodule