module Instruction_Decode#(
    parameter XLEN = 32
)(
    input clk_i,
    input rst_i,
    input stall_i,
    input flush_i,
    input branch_hit_i, // from instruction fetch stage
    input branch_taken_i, // from instruction fetch stage
    input reg_we_i, // write enable signal for register file
    input [XLEN-1:0] pc_i,  
    input [XLEN-1:0] instr_i, 
    input [4:0] rs1_i,
    input [4:0] rs2_i,
    input [4:0] rd_i,
    input [2:0] funct3_i,
    input [6:0] funct7_i,
    input [3:0] alu_control_i,
    input [XLEN-1:0] imm_i, // from immediate generator
    input [XLEN-1:0] rs1_data_i, 
    input [XLEN-1:0] rs2_data_i, 
    output reg [XLEN-1:0] pc_o, 
    output reg [XLEN-1:0] instr_o,
    output reg branch_hit_o, 
    output reg branch_taken_o, 
    output reg reg_we_o, 
    output reg [4:0] rs1_o, // to register file
    output reg [4:0] rs2_o, // to register file
    output reg [4:0] rd_o, 
    output reg [2:0] funct3_o, // to EX stage and control unit
    output reg [6:0] funct7_o, // to EX stage and control unit
    output reg [3:0] alu_control_o, // to ALU, from control unit
    output reg [XLEN-1:0] imm_o, 
    output reg [XLEN-1:0] rs1_data_o, 
    output reg [XLEN-1:0] rs2_data_o 
);

always @(posedge clk_i)begin
    if(rst_i)begin
        pc_o <= 0;
        instr_o <= 32'h00000013; // NOP instruction
        branch_hit_o <= 0;
        branch_taken_o <= 0;
        reg_we_o <= 0;
        rs1_o <= 0;
        rs2_o <= 0;
        rd_o <= 0;
        funct3_o <= 0;
        funct7_o <= 0;
        imm_o <= 0;
        rs1_data_o <= 0;
        rs2_data_o <= 0;
        alu_control_o <= 4'b1111; // NOP
    end
    else if(flush_i)begin
        pc_o <= pc_i;
        instr_o <= 32'h00000013; // NOP instruction
        branch_hit_o <= 0;
        branch_taken_o <= 0;
        reg_we_o <= 0;
        rs1_o <= 0; 
        rs2_o <= 0;
        rd_o <= 0;
        funct3_o <= 0;
        funct7_o <= 0;
        imm_o <= 0;
        rs1_data_o <= 0;
        rs2_data_o <= 0;
        alu_control_o <= 4'b1111; // NOP
    end
    else if(stall_i)begin
        pc_o <= pc_o;
        instr_o <= instr_o;
        branch_hit_o <= branch_hit_o;
        branch_taken_o <= branch_taken_o;
        reg_we_o <= reg_we_o;
        rs1_o <= rs1_o; 
        rs2_o <= rs2_o;
        rd_o <= rd_o;
        funct3_o <= funct3_o;
        funct7_o <= funct7_o;
        imm_o <= imm_o;
        rs1_data_o <= rs1_data_o;
        rs2_data_o <= rs2_data_o;
        alu_control_o <= alu_control_o;
    end
    else begin
        pc_o <= pc_i;
        instr_o <= instr_i;
        branch_hit_o <= branch_hit_i;
        branch_taken_o <= branch_taken_i;
        reg_we_o <= reg_we_i;
        rs1_o <= rs1_i; 
        rs2_o <= rs2_i;
        rd_o <= rd_i;
        funct3_o <= funct3_i;
        funct7_o <= funct7_i;
        imm_o <= imm_i;
        rs1_data_o <= rs1_data_i;
        rs2_data_o <= rs2_data_i;
        alu_control_o <= alu_control_i;
    end
end



endmodule