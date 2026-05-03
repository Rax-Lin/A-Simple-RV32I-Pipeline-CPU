// Rax work
// Only support RV32I base instruction set, without any extension.
// This CPU doesn't support the following function
// 1. CSR instructions
// 2. Interrupt and exception handling

`include "CPU_config.vh"
module CPU#(
    parameter XLEN = 32,
    parameter MEM_FILE = "testcase/program.txt" // Default instruction memory file
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
// PC_o, instr_o from IF stage to ID stage
// from Branch Prediction Unit(BPU)
wire branch_hit_i, branch_taken_i; // to instruction fetch stage



// ID stage signal
localparam REG_NUM = 32;
wire [XLEN-1:0] id_PC, id_instr; 
wire id_reg_we; // write enable signal for register file, to exe stage
wire id_is_branch; // to exe stage for branch decision
wire id_mem_read, id_mem_write;
wire id_is_jal, id_is_jalr;
wire [2:0] id_branch_type; 
wire id_branch_hit, id_branch_taken; // from instruction fetch stage
wire [6:0] id_opcode; // to control unit
wire [4:0] id_rs1, id_rs2, id_rd; // to register file and exe stage
wire [2:0] id_funct3; 
wire [6:0] id_funct7; 
wire [3:0] id_alu_control; // to ALU, from control unit
wire [1:0] id_alu_src1, id_alu_src2; // to ALU, from control unit
wire [XLEN-1:0] id_rs1_data, id_rs2_data; // from register file
wire [XLEN-1:0] id_imm; // from immediate generator

// EX stage signal
wire [XLEN-1:0] exe_PC, exe_instr, exe_branch_target_address;
wire exe_reg_we; // write enable signal for register file, to MEM stage
wire exe_branch_hit, exe_branch_taken; // from instruction fetch stage
wire exe_mem_read, exe_mem_write;
wire exe_is_branch, exe_is_jal, exe_is_jalr; // from control unit for branch decision
wire [2:0] exe_branch_type; // from control unit for branch decision
wire exe_alu_is_zero; // from ALU to BPU for branch decision
wire [4:0] exe_rs1, exe_rs2, exe_rd; 
wire [3:0] exe_alu_control; // to ALU, from control unit
wire [1:0] exe_alu_src1, exe_alu_src2; // to ALU, from control unit
wire [XLEN-1:0] exe_rs1_data, exe_rs2_data, exe_forwardA_data, exe_forwardB_data; // from register file and forwarding unit
wire [XLEN-1:0] exe_alu_src_output1, exe_alu_src_output2; // to ALU src select mux
wire [XLEN-1:0] exe_alu_result; // from ALU to MEM stage
wire [XLEN-1:0] exe_pc_plus_4; // for JAL/JALR write-back
wire [1:0] forwardA, forwardB; // from forwarding unit
wire [XLEN-1:0] exe_imm; // from immediate generator

// MEM stage signal
wire [XLEN-1:0] mem_PC, mem_pc_plus_4, mem_branch_target_address, mem_data_memory_output;
wire mem_reg_we;
wire mem_branch_hit, mem_branch_taken;
wire mem_mem_read, mem_mem_write;
wire mem_is_branch, mem_is_jal, mem_is_jalr;
wire [2:0] mem_branch_type, mem_funct3; 
wire [4:0] mem_rd; // to WB stage
wire [XLEN-1:0] mem_alu_result; // from EX stage
wire mem_alu_is_zero; // from EX stage  
wire [XLEN-1:0] mem_alu_src_output2; // from EX stage, for store instruction
wire [1:0] mem_pc_src_sel; // control signal for PC source selection, from control unit(MEM return)

// WB stage signal
wire mem_branch_is_taken; // the true branch decision result
wire wb_reg_we; // write enable signal for register file, from control unit
wire [4:0] wb_rd; // write destination register address, from WB stage
wire wb_is_jal, wb_is_jalr;
wire wb_mem_read; // from MEM/WB register, to select write-back data
wire [XLEN-1:0] wb_alu_result;
wire [XLEN-1:0] wb_pc_plus_4;
wire [XLEN-1:0] wb_data_memory_read_data;
wire [XLEN-1:0] wb_rd_data; // write data, from WB



// jump and branch related signal
wire [XLEN-1:0] branch_target_address, jump_target_address;
wire [1:0] PC_src_sel; // control signal for PC source selection

// IF stage
assign branch_hit_i = 0;
assign branch_taken_i = 0; // default setting before bpu apply
assign PC_src_sel = (mem_is_jal || mem_is_jalr) ? 2'b10 : // jump instruction has higher priority than branch instruction
                    (mem_is_branch && mem_branch_is_taken) ? 2'b01 : //  branch instruction and branch taken, select branch target address
                    2'b00; // default is PC + 4
Instr_MEM #(
    .XLEN(XLEN),
    .DEPTH(1024),
    .BASE_ADDR(32'h0000_0000),
    .MEM_FILE(MEM_FILE) // Use the parameter passed to the CPU module
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
) pc_adder (
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
    .sel_i(PC_src_sel), // control signal from control unit(MEM return) (branch, jump or normal)
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
    .is_branch_o(id_is_branch), // to exe stage for branch decision
    .mem_read_o(id_mem_read),
    .mem_write_o(id_mem_write),
    .is_jal_o(id_is_jal),
    .is_jalr_o(id_is_jalr),
    .branch_type_o(id_branch_type),
    .alu_control_o(id_alu_control), // to ALU, control the ALU operation
    .alu_src1_o(id_alu_src1), // to ALU, control the first operand source: 00 - register, 01 - PC, 10 - zero
    .alu_src2_o(id_alu_src2) // to ALU, control the second operand source:
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

Instruction_Decode #(
    .XLEN(XLEN)
) ID (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .stall_i(stall_o),
    .flush_i(flush_o),
    .mem_read_i(id_mem_read),
    .mem_write_i(id_mem_write),
    .reg_we_i(id_reg_we), // write enable signal for register file, from control unit
    .pc_i(id_PC),  
    .instr_i(id_instr), 
    .rs1_i(id_rs1),
    .rs2_i(id_rs2),
    .rd_i(id_rd),
    .alu_control_i(id_alu_control), // from control unit
    .imm_i(id_imm), // from immediate generator
    .rs1_data_i(id_rs1_data), 
    .rs2_data_i(id_rs2_data), 
    .alu_src1_i(id_alu_src1), // from control unit
    .alu_src2_i(id_alu_src2), // from control unit
    // To MEM stage
    .branch_hit_i(id_branch_hit), // from instruction fetch stage
    .branch_taken_i(id_branch_taken), // from instruction fetch stage
    .is_branch_i(id_is_branch), // from control unit for branch decision
    .is_jal_i(id_is_jal),
    .is_jalr_i(id_is_jalr),
    .branch_type_i(id_branch_type), // from control unit for branch decision
    // Output
    .pc_o(exe_PC), 
    .instr_o(exe_instr),
    .reg_we_o(exe_reg_we), 
    .rs1_o(exe_rs1), // to register file
    .mem_read_o(exe_mem_read),
    .mem_write_o(exe_mem_write),
    .rs2_o(exe_rs2), // to register file
    .rd_o(exe_rd), 
    .alu_control_o(exe_alu_control), // to ALU, from control unit
    .imm_o(exe_imm), 
    .rs1_data_o(exe_rs1_data), 
    .rs2_data_o(exe_rs2_data),
    .alu_src1_o(exe_alu_src1),
    .alu_src2_o(exe_alu_src2),
    // To MEM stage
    .branch_hit_o(exe_branch_hit), // to instruction fetch stage
    .branch_taken_o(exe_branch_taken), // to instruction fetch stage
    .is_branch_o(exe_is_branch), // to exe stage for branch decision
    .is_jal_o(exe_is_jal),
    .is_jalr_o(exe_is_jalr),
    .branch_type_o(exe_branch_type) // to exe stage for branch decision
);

// Hazard Detection Unit
// Detects load-use hazards and generates a stall signal.
Hazard_Detection hazard_detection_unit (
    // Source registers of the instruction in ID stage
    .id_rs1_i(id_rs1),
    .id_rs2_i(id_rs2),
    // Destination register and control signals from EX stage
    .exe_rd_i(exe_rd),
    .exe_mem_read_i(exe_mem_read),
    .exe_reg_we_i(exe_reg_we), // Not used for load-use, but good practice
    .stall_o(stall_o)
);


// EX stage
// note LUI, AUIPC, JAL, JALR have special handling
// LUI = 0 + imm[31:12] << 12, set src1 to 0
// AUIPC = PC + imm[31:12] << 12, set src1 to PC
// JAL = PC + imm, set src1 to PC
// JALR = rs1 + imm
Adder #(
    .XLEN(XLEN)
) exe_adder (
    .src1_i(exe_PC), // from ID stage
    .src2_i(exe_imm), // from ID stage, no need to shift
    .sum_o(exe_branch_target_address) // to BPU
);

Adder #(
    .XLEN(XLEN)
) exe_pc_plus_4_adder (
    .src1_i(exe_PC), // from ID stage
    .src2_i(4),
    .sum_o(exe_pc_plus_4)
);

MUX3 #(
    .XLEN(XLEN)
) exe_forwardA_mux (
    .in0_i(exe_rs1_data), // from ID stage
    .in1_i(mem_alu_result), // MEM data (from ALU result)
    .in2_i(wb_rd_data), // WB data
    .sel_i(forwardA), // forwarding control signal
    .out_o(exe_forwardA_data) // to ALU src1 select
);

MUX3 #(
    .XLEN(XLEN)
) exe_forwardB_mux (
    .in0_i(exe_rs2_data), // from ID stage
    .in1_i(mem_alu_result), // from MEM stage (from ALU result)
    .in2_i(wb_rd_data), // from WB stage
    .sel_i(forwardB), // forwarding control signal
    .out_o(exe_forwardB_data) // to ALU src2 select
);

Forwarding_Unit forwarding_unit (
    // Source register addresses in EX stage
    .exe_rs1_i(exe_rs1),
    .exe_rs2_i(exe_rs2),

    // Destination register addresses from later stages
    .mem_rd_i(mem_rd),
    .wb_rd_i(wb_rd),
    .mem_reg_we_i(mem_reg_we),
    .wb_reg_we_i(wb_reg_we),

    .forwardA_o(forwardA),
    .forwardB_o(forwardB)
);

MUX3 #(
    .XLEN(XLEN)
) exe_alu_src1_mux (
    .in0_i(exe_forwardA_data), // from ID stage
    .in1_i(exe_PC), // from ID stage
    .in2_i(0), // zero
    .sel_i(exe_alu_src1), // from control unit
    .out_o(exe_alu_src_output1) // to ALU src1
);

MUX3 #(
    .XLEN(XLEN)
) exe_alu_src2_mux (
    .in0_i(exe_forwardB_data), // from ID stage
    .in1_i(exe_imm), // from ID stage
    .in2_i(4), // for PC + 4, used in JAL instruction
    .sel_i(exe_alu_src2), // from control unit
    .out_o(exe_alu_src_output2) // to ALU src2
);

ALU #(
    .XLEN(XLEN)
) alu (
    .src1_i(exe_alu_src_output1), // from exe_alu_src1_mux
    .src2_i(exe_alu_src_output2), // from exe_alu_src2_mux
    .alu_control_i(exe_alu_control), // from control unit
    .alu_result_o(exe_alu_result), // to MEM stage
    .is_zero_o(exe_alu_is_zero) // to BPU for branch decision
);

Execution #(
    .XLEN(XLEN)
) exe (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush_i(flush_o),
    .PC_i(exe_PC), // from ID stage
    .pc_plus_4_i(exe_pc_plus_4),
    .branch_target_address_i(exe_branch_target_address), // from adder
    .alu_result_i(exe_alu_result), // from ALU
    .alu_is_zero_i(exe_alu_is_zero), // from ALU to BPU for branch decision
    .alu_src_output2_i(exe_alu_src_output2), // for store instruction, to MEM stage
    // For Mem stage
    .mem_read_i(exe_mem_read),
    .mem_write_i(exe_mem_write),
    .is_branch_i(exe_is_branch), // from control unit for branch decision
    .is_jal_i(exe_is_jal),
    .is_jalr_i(exe_is_jalr),
    .branch_type_i(exe_branch_type), // from control unit for branch decision
    .branch_hit_i(exe_branch_hit), // from instruction fetch stage
    .branch_taken_i(exe_branch_taken), // from instruction fetch stage
    // For WB stage
    .reg_we_i(exe_reg_we), // write enable signal for register file, from control unit
    .rd_i(exe_rd), // destination register address, for write back stage

    .PC_o(mem_PC), 
    .pc_plus_4_o(mem_pc_plus_4),
    .branch_target_address_o(mem_branch_target_address), 
    .alu_result_o(mem_alu_result), 
    .alu_is_zero_o(mem_alu_is_zero), 
    .alu_src_output2_o(mem_alu_src_output2), 
    // For Mem stage
    .mem_read_o(mem_mem_read),
    .mem_write_o(mem_mem_write),
    .branch_hit_o(mem_branch_hit), 
    .branch_taken_o(mem_branch_taken),
    .is_branch_o(mem_is_branch),
    .is_jal_o(mem_is_jal),
    .is_jalr_o(mem_is_jalr),
    .branch_type_o(mem_branch_type),

    // For WB stage
    .rd_o(mem_rd), 
    .reg_we_o(mem_reg_we) 
);

// MEM stage

Branch_Comparator #(
    .XLEN(XLEN)
) branch_comparator (
    .alu_result_i(mem_alu_result), // from EX stage
    .alu_is_zero_i(mem_alu_is_zero), // from EX stage to BPU for branch decision
    .branch_type_i(mem_branch_type), // from control unit for branch decision
    .branch_taken_o(mem_branch_is_taken) // to instruction fetch stage
);

assign branch_target_address = mem_branch_target_address;
// The funct3 field is needed in the MEM stage for load/store instructions.
// Since Control_Unit sets branch_type to funct3, we pass it through the pipeline using the mem_branch_type wire.
assign mem_funct3 = mem_branch_type;
assign jump_target_address = mem_alu_result; // for JAL and JALR, the jump target address is calculated by ALU
// A branch misprediction occurs if the instruction was a branch, but the actual outcome (`mem_branch_is_taken`)
// is different from the predicted outcome (`mem_branch_taken`).
wire branch_mispredict = mem_is_branch && (mem_branch_is_taken != mem_branch_taken);
assign flush_o = (mem_is_jal || mem_is_jalr) || branch_mispredict;

Data_Memory #(
    .XLEN(XLEN),
    .MEM_SIZE(1024)
) data_memory (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .mem_read_i(mem_mem_read), // from control unit, pipelined
    .mem_write_i(mem_mem_write), // from control unit, pipelined
    .funct3_i(mem_funct3), // from EX stage, determines access size
    .addr_i(mem_alu_result), // from EX stage, the memory address to access
    .write_data_i(mem_alu_src_output2), // from EX stage, the data to be written for store instruction
    .read_data_o(mem_data_memory_output) // to WB stage, the data read from memory for load instruction
);



// WB stage
Memory #(
    .XLEN(XLEN)
) mem_wb_reg (
    .clk_i(clk_i),
    .rst_i(rst_i),
    // from MEM stage logic
    .rd_i(mem_rd),
    .reg_we_i(mem_reg_we),
    .is_jal_i(mem_is_jal),
    .is_jalr_i(mem_is_jalr),
    .mem_read_i(mem_mem_read), // from EX/MEM register
    .pc_plus_4_i(mem_pc_plus_4),
    .alu_result_i(mem_alu_result),
    .data_memory_read_data_i(mem_data_memory_output), // from Data_Memory
    // To WB stage
    .wb_rd_o(wb_rd),
    .wb_reg_we_o(wb_reg_we),
    .wb_is_jal_o(wb_is_jal),
    .wb_is_jalr_o(wb_is_jalr),
    .wb_mem_read_o(wb_mem_read),
    .wb_pc_plus_4_o(wb_pc_plus_4),
    .wb_alu_result_o(wb_alu_result),
    .wb_data_memory_read_data_o(wb_data_memory_read_data)
);

// Select data to write back to register file.
assign wb_rd_data = (wb_is_jal || wb_is_jalr) ? wb_pc_plus_4 : // For JAL/JALR, write back PC+4
                    wb_mem_read ? wb_data_memory_read_data :   // For loads, write back data from memory
                    wb_alu_result;                             // For all others, write back ALU result



endmodule