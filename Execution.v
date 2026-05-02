module Execution#(
    parameter XLEN = 32
)(
    input clk_i,
    input rst_i,
    input flush_i,
    input [XLEN-1:0] PC_i,
    input [XLEN-1:0] pc_plus_4_i,
    input [XLEN-1:0] branch_target_address_i,
    input [XLEN-1:0] alu_result_i,
    input alu_is_zero_i,
    input [XLEN-1:0] alu_src_output2_i,
    // For Mem stage
    input is_branch_i, // from control unit for branch decision
    input is_jal_i,
    input is_jalr_i,
    input [2:0] branch_type_i, // from control unit for branch decision
    input branch_hit_i, // from instruction fetch stage
    input branch_taken_i, // from instruction fetch stage
    input mem_read_i, // from ID stage
    input mem_write_i, // from ID stage
    // For WB stage
    input reg_we_i, // write enable signal for register file
    input [4:0] rd_i, // destination register address, for write back stage

    output reg [XLEN-1:0] PC_o,
    output reg [XLEN-1:0] pc_plus_4_o,
    output reg [XLEN-1:0] branch_target_address_o,
    output reg [XLEN-1:0] alu_result_o,
    output reg alu_is_zero_o,
    output reg [XLEN-1:0] alu_src_output2_o,
    // For Mem stage
    output reg branch_hit_o, 
    output reg branch_taken_o,
    output reg is_branch_o,
    output reg is_jal_o,
    output reg is_jalr_o,
    output reg [2:0] branch_type_o,
    output reg mem_read_o,
    output reg mem_write_o,

    // For WB stage
    output reg [4:0] rd_o, 
    output reg reg_we_o 
);

always @(posedge clk_i)begin
    if(rst_i)begin
        PC_o <= 0;
        pc_plus_4_o <= 0;
        branch_target_address_o <= 0;
        alu_result_o <= 0;
        alu_is_zero_o <= 0;
        alu_src_output2_o <= 0;
        branch_hit_o <= 0;
        branch_taken_o <= 0;
        is_branch_o <= 0;
        is_jal_o <= 0;
        is_jalr_o <= 0;
        branch_type_o <= 0;
        rd_o <= 0;
        mem_read_o <= 0;
        mem_write_o <= 0;
        reg_we_o <= 0;
    end else if(flush_i) begin
        PC_o <= 0;
        pc_plus_4_o <= 0;
        branch_target_address_o <= 0;
        alu_result_o <= 0;
        alu_is_zero_o <= 0;
        alu_src_output2_o <= 0;
        branch_hit_o <= 0;
        branch_taken_o <= 0;
        is_branch_o <= 0;
        is_jal_o <= 0;
        is_jalr_o <= 0;
        branch_type_o <= 0;
        rd_o <= 0;
        mem_read_o <= 0;
        mem_write_o <= 0;
        reg_we_o <= 0;
    end
    else begin
        PC_o <= PC_i;
        pc_plus_4_o <= pc_plus_4_i;
        branch_target_address_o <= branch_target_address_i;
        alu_result_o <= alu_result_i;
        alu_is_zero_o <= alu_is_zero_i;
        alu_src_output2_o <= alu_src_output2_i;
        branch_hit_o <= branch_hit_i;
        branch_taken_o <= branch_taken_i;
        is_branch_o <= is_branch_i;
        is_jal_o <= is_jal_i;
        is_jalr_o <= is_jalr_i;
        branch_type_o <= branch_type_i;
        rd_o <= rd_i;
        mem_read_o <= mem_read_i;
        mem_write_o <= mem_write_i;
        reg_we_o <= reg_we_i; 
    end
end

endmodule