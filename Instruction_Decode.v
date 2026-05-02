module Instruction_Decode#(
    parameter XLEN = 32
)(
    input clk_i,
    input rst_i,
    input stall_i,
    input flush_i,
    input [XLEN-1:0] pc_i,  
    input [XLEN-1:0] instr_i, 
    input mem_read_i,
    input mem_write_i,
    input [4:0] rs1_i,
    input [4:0] rs2_i,
    input [4:0] rd_i,
    input [3:0] alu_control_i,
    input [XLEN-1:0] imm_i, // from immediate generator
    input [XLEN-1:0] rs1_data_i, 
    input [XLEN-1:0] rs2_data_i, 
    input [1:0] alu_src1_i,
    input [1:0] alu_src2_i,
    // For Mem stage
    input is_branch_i, // from control unit for branch decision
    input is_jal_i,
    input is_jalr_i,
    input [2:0] branch_type_i, // from control unit for branch decision
    input branch_hit_i, // from instruction fetch stage
    input branch_taken_i, // from instruction fetch stage
    // For WB stage
    input reg_we_i, // write enable signal for register file

    output reg [XLEN-1:0] pc_o, 
    output reg [XLEN-1:0] instr_o,
    output reg [4:0] rs1_o, // to register file
    output reg [4:0] rs2_o, // to register file
    output reg [4:0] rd_o, 
    output reg [3:0] alu_control_o, // to ALU, from control unit
    output reg [XLEN-1:0] imm_o, 
    output reg [XLEN-1:0] rs1_data_o, 
    output reg [XLEN-1:0] rs2_data_o,
    output reg [1:0] alu_src1_o,
    output reg [1:0] alu_src2_o,
    output reg mem_read_o,
    output reg mem_write_o,
    // For Mem stage
    output reg is_branch_o, // to exe stage for branch decision
    output reg is_jal_o,
    output reg is_jalr_o,
    output reg [2:0] branch_type_o, // to exe stage for branch decision
    output reg branch_hit_o, // to instruction fetch stage
    output reg branch_taken_o, // to instruction fetch stage
    // For WB stage 
    output reg reg_we_o
);

always @(posedge clk_i)begin
    if(rst_i)begin
        pc_o <= 0;
        instr_o <= 32'h00000013; // NOP instruction
        branch_hit_o <= 0;
        branch_taken_o <= 0;
        is_branch_o <= 0;
        is_jal_o <= 0;
        is_jalr_o <= 0;
        branch_type_o <= 0;
        reg_we_o <= 0;
        rs1_o <= 0;
        rs2_o <= 0;
        rd_o <= 0;
        imm_o <= 0;
        mem_read_o <= 0;
        mem_write_o <= 0;
        rs1_data_o <= 0;
        rs2_data_o <= 0;
        alu_control_o <= 4'b1111; // NOP
        alu_src1_o <= 2'b00; // rs1
        alu_src2_o <= 2'b00; // rs2
    end
    else if(flush_i)begin
        pc_o <= pc_i;
        instr_o <= 32'h00000013; // NOP instruction
        branch_hit_o <= 0;
        branch_taken_o <= 0;
        is_branch_o <= 0;
        is_jal_o <= 0;
        is_jalr_o <= 0;
        branch_type_o <= 0;
        reg_we_o <= 0;
        rs1_o <= 0; 
        rs2_o <= 0;
        rd_o <= 0;
        imm_o <= 0;
        mem_read_o <= 0;
        mem_write_o <= 0;
        rs1_data_o <= 0;
        rs2_data_o <= 0;
        alu_control_o <= 4'b1111; // NOP
        alu_src1_o <= 2'b00; // rs1
        alu_src2_o <= 2'b00; // rs2
    end
    else if(stall_i)begin // On stall, insert a bubble (NOP) into the pipeline
        pc_o <= pc_i;
        instr_o <= 32'h00000013; // NOP instruction
        branch_hit_o <= 0;
        branch_taken_o <= 0;
        is_branch_o <= 0;
        is_jal_o <= 0;
        is_jalr_o <= 0;
        branch_type_o <= 0;
        reg_we_o <= 0;
        rs1_o <= 0; 
        rs2_o <= 0;
        rd_o <= 0;
        imm_o <= 0;
        rs1_data_o <= 0;
        rs2_data_o <= 0;
        mem_read_o <= 0;
        mem_write_o <= 0;
        alu_control_o <= 4'b1111; // NOP
        alu_src1_o <= 2'b00; // rs1
        alu_src2_o <= 2'b00; // rs2
    end
    else begin
        pc_o <= pc_i;
        instr_o <= instr_i;
        branch_hit_o <= branch_hit_i;
        branch_taken_o <= branch_taken_i;
        is_branch_o <= is_branch_i;
        is_jal_o <= is_jal_i;
        is_jalr_o <= is_jalr_i;
        branch_type_o <= branch_type_i;
        reg_we_o <= reg_we_i;
        rs1_o <= rs1_i; 
        rs2_o <= rs2_i;
        rd_o <= rd_i;
        imm_o <= imm_i;
        mem_read_o <= mem_read_i;
        mem_write_o <= mem_write_i;
        rs1_data_o <= rs1_data_i;
        rs2_data_o <= rs2_data_i;
        alu_control_o <= alu_control_i;
        alu_src1_o <= alu_src1_i;
        alu_src2_o <= alu_src2_i;
    end
end



endmodule