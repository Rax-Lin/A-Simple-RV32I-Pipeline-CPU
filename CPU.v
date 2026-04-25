// Rax work
// This CPU doesn't support the following function
// 1. CSR instructions
// 2. Interrupt and exception handling

`include "CPU_config.vh"
module CPU#(
    parameter XLEN = 32
)
(
    input clk_i,
    input rst_i

    // IF stage signal
    // ID stage signal
    // EX stage signal
    // MEM stage signal
    // WB stage signal
);
// control unit signal
wire stall_i; // from hazard detection unit, used to control the program counter and pipeline register.

// program counter related signal
wire [XLEN-1:0] PC_o, PC_next, PC_add; 
wire [XLEN-1:0] instr_o; // instruction memory

// IF stage signal
wire [XLEN-1:0] if2id_PC, if2id_instr; 
wire if2id_branch_hit_o, if2id_branch_taken_o; // from instruction fetch stage

// from Branch Prediction Unit(BPU)
wire branch_hit_i, branch_taken_i; // to instruction fetch stage

// jump and branch related signal
wire [XLEN-1:0] branch_target_address, jump_target_address;
wire [1:0] PC_src_sel; // control signal for PC source selection

// IF stage
Instr_MEM #(
    .XLEN(XLEN),
    .DEPTH(1024),
    .BASE_ADDR(32'h0000_0000),
    .MEM_FILE("testcase/program.txt") // input file position
) instr_mem (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .PC_i(PC_o),
    .instr_o(instr_o)
);

Program_Counter #(
    .XLEN(XLEN)
) PC (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .stall_i(stall_i),
    .PC_i(PC_next), // source : PC + 4, branch target address, jump target address
    .PC_o(PC_o)
);

Adder #(
    .XLEN(XLEN)
) adder (
    .src1_i(PC_o),
    .src2_i(4), // next instruction address = current PC + 4
    .sum_o(PC_add)
);

// 0: PC + 4, 1: branch target address, 2: jump target address
MUX3 #(
    .XLEN(XLEN)
) PC_src_mux (
    .in0_i(PC_add), // next instruction address
    .in1_i(branch_target_address), // branch target address
    .in2_i(jump_target_address), // jump target address
    .sel_i(PC_src_sel), // control signal from control unit (branch, jump or normal)
    .out_o(PC_next) // to program counter
);

Instruction_Fetch #(
    .XLEN(XLEN)
) IF (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .stall_i(stall_i),
    .flush_i(flush_i),
    .instr_i(instr_o), // from instruction memory
    .PC_i(PC_o), // from program counter
    .branch_hit_i(branch_hit_i), // from BPU
    .branch_taken_i(branch_taken_i) // from BPU
    .PC_o(if2id_PC), // to ID stage
    .instr_o(if2id_instr), // to ID stage
    .branch_hit_o(if2id_branch_hit_o), // to ID stage
    .branch_taken_o(if2id_branch_taken_o) // to ID stage
);

// ID stage

// EX stage
// note LUI, AUIPC, JAL, JALR have special handling

// LUI = 0 + imm[31:12] << 12, set src1 to 0
// AUIPC = PC + imm[31:12] << 12, set src1 to PC
// JAL = PC + imm, set src1 to PC
// JALR = rs1 + imm





// MEM stage
// WB stage

endmodule