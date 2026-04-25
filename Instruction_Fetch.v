module Instruction_Fetch#(
    parameter XLEN = 32
)(
    input clk_i,
    input rst_i,
    input stall_i,
    input flush_i,
    // from instr mem
    input [XLEN-1:0] instr_i,
    // from program counter
    input [XLEN-1:0] PC_i, 
    // from BPU
    input branch_hit_i, // if the result is useful
    input branch_taken_i,

    output reg [XLEN-1:0] PC_o,
    output reg [XLEN-1:0] instr_o,
    output reg branch_hit_o,
    output reg branch_taken_o
);

always @(posedge clk_i)begin
    if(rst_i)begin
        PC_o <= 0;
        instr_o <= 32'h00000013; // NOP instruction
        branch_hit_o <= 0;
        branch_taken_o <= 0;
    end
    else if(flush_i)begin
        PC_o <= PC_i; // flush the instruction and program counter when flush (branch misprediction)
        instr_o <= 32'h00000013; // NOP instruction
        branch_hit_o <= 0;
        branch_taken_o <= 0;
    end
    else if(stall_i)begin
        PC_o <= PC_o; // do not update the instruction and program counter when stall
        instr_o <= instr_o;
        branch_hit_o <= branch_hit_o;
        branch_taken_o <= branch_taken_o; // the decision of branch prediction unit
    end
    else begin
        PC_o <= PC_i; // update the instruction and program counter when normal
        instr_o <= instr_i;
        branch_hit_o <= branch_hit_i;
        branch_taken_o <= branch_taken_i;
    end
end


endmodule
