// Rax work
// Only support RV32I base instruction set, without any extension.
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
wire stall_o, flush_o; // from hazard detection unit, used to control the program counter and pipeline register.

// program counter related signal
wire [XLEN-1:0] PC_o, PC_next, PC_add; 
wire [XLEN-1:0] instr_o; // instruction memory

// IF stage signal
wire [XLEN-1:0] id_PC, id_instr; 
wire id_branch_hit, id_branch_taken; // from instruction fetch stage

// ID stage signal
localparam REG_NUM = 32;
wire [XLEN-1:0] id2exe_PC;
wire id_reg_we; // write enable signal for register file, to exe stage
wire [6:0] id_opcode; // to control unit
wire [4:0] id_rs1, id_rs2, id_rd; // to register file
wire [2:0] id_funct3; 
wire [6:0] id_funct7; 
wire [3:0] id_alu_control; // to ALU, from control unit
wire [XLEN-1:0] id_rs1_data, id_rs2_data; // from register file
wire [XLEN-1:0] id_imm; // from immediate generator

// EX stage signal

// MEM stage signal

// WB stage signal
wire wb_reg_we; // write enable signal for register file, from control unit
wire [4:0] wb_rd; // write destination register address, from WB stage
wire [XLEN-1:0] wb_rd_data; // write data, from WB

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
    .stall_i(stall_o),
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
    .stall_i(stall_o),
    .flush_i(flush_o),
    .instr_i(instr_o), // from instruction memory
    .PC_i(PC_o), // from program counter
    .branch_hit_i(branch_hit_i), // from BPU
    .branch_taken_i(branch_taken_i), // from BPU
    .PC_o(id_PC), // to ID stage
    .instr_o(id_instr), // to ID stage
    .branch_hit_o(id_branch_hit), // to ID stage
    .branch_taken_o(id_branch_taken) // to ID stage
);

// ID stage

Instruction_Parser #(
    .XLEN(XLEN)
) instr_parser (
    .instr_i(id_instr), // from IF stage
    .opcode_o(id_opcode), // to control unit
    .rs1_o(id_rs1), // to register file
    .rs2_o(id_rs2), // to register file
    .rd_o(id_rd), // to EX stage
    .funct3_o(id_funct3), // to EX stage and control unit
    .funct7_o(id_funct7) // to EX stage and control unit
);

Control_Unit control_unit (
    .opcode_i(id_opcode), // from instruction parser
    .funct3_i(id_funct3), // from instruction parser
    .funct7_i(id_funct7), // from instruction parser
    .reg_we_o(id_reg_we), // to register file
    .alu_control_o(id_alu_control) // to ALU, control the ALU operation
);

Register_file#(
    .XLEN(XLEN),
    .REG_NUM(REG_NUM)
) reg_file (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rs1_addr_i(id_rs1), 
    .rs1_data_o(id_rs1_data), // to EX stage
    .rs2_addr_i(id_rs2), 
    .rs2_data_o(id_rs2_data), // to EX stage
    .we_i(wb_reg_we), // write enable, from WB stage
    .rd_addr_i(wb_rd), // write destination register address, from WB stage
    .rd_data_i(wb_rd_data) // write data, from WB stage
);

Immediate_Generator #(
    .XLEN(XLEN)
) imm_gen (
    .instr_i(id_instr), 
    .imm_o(id_imm) // to EX stage
);

// instruction_decode module

// EX stage
// note LUI, AUIPC, JAL, JALR have special handling

// LUI = 0 + imm[31:12] << 12, set src1 to 0
// AUIPC = PC + imm[31:12] << 12, set src1 to PC
// JAL = PC + imm, set src1 to PC
// JALR = rs1 + imm





// MEM stage
// WB stage

endmodule