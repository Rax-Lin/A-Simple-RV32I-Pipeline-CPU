module Memory#(
    parameter XLEN = 32
)(
    input clk_i,
    input rst_i,
    input [4:0] rd_i,
    input reg_we_i,
    input is_jal_i,
    input is_jalr_i,
    input mem_read_i, // Control signal for load instructions
    input [XLEN-1:0] pc_plus_4_i,
    input [XLEN-1:0] alu_result_i,
    input [XLEN-1:0] data_memory_read_data_i, // Data read from Data_Memory

    // To WB stage
    output reg [4:0] wb_rd_o,
    output reg wb_reg_we_o,
    output reg wb_is_jal_o,
    output reg wb_is_jalr_o,
    output reg wb_mem_read_o,
    output reg [XLEN-1:0] wb_pc_plus_4_o,
    output reg [XLEN-1:0] wb_alu_result_o,
    output reg [XLEN-1:0] wb_data_memory_read_data_o
);
always @(posedge clk_i) begin
    if (rst_i) begin
        wb_rd_o <= 0;
        wb_reg_we_o <= 0;
        wb_is_jal_o <= 0;
        wb_is_jalr_o <= 0;
        wb_mem_read_o <= 0;
        wb_pc_plus_4_o <= 0;
        wb_alu_result_o <= 0;
        wb_data_memory_read_data_o <= 0;
    end else begin 
        wb_rd_o <= rd_i;
        wb_reg_we_o <= reg_we_i;
        wb_is_jal_o <= is_jal_i;
        wb_is_jalr_o <= is_jalr_i;
        wb_mem_read_o <= mem_read_i;
        wb_pc_plus_4_o <= pc_plus_4_i;
        wb_alu_result_o <= alu_result_i;
        wb_data_memory_read_data_o <= data_memory_read_data_i;
    end
end
endmodule