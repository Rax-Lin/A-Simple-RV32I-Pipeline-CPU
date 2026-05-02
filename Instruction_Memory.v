module Instr_MEM#(
    parameter XLEN      = 32,
    parameter DEPTH     = 1024,                // word number of instruction memory
    parameter BASE_ADDR = 32'h0000_0000,
    parameter MEM_FILE  = "testcase/program2.txt"
)(
    input clk_i,
    input rst_i, // for future usage
    // Prgoram Counter
    input [XLEN-1:0] PC_i,
    output [XLEN-1:0] instr_o
);

    reg [XLEN-1:0] instr_rom [0:DEPTH-1];
    wire [XLEN-1:0] byte_off = PC_i - BASE_ADDR;
    wire [$clog2(DEPTH)-1:0] word_idx = byte_off[XLEN-1:2]; // word aligned
    wire valid_range = (byte_off[1:0] == 2'b00) && (word_idx < DEPTH); // check if the address is word aligned and within the memory range
    
    // instruction initialize
    integer i;
    initial begin
        // 1. Initialize memory with NOPs in case the file is shorter than the memory depth.
        for (i = 0; i < DEPTH; i = i + 1) begin
            instr_rom[i] = 32'h00000013; // NOP
        end
        // 2. Load instructions from the specified file.
        // The simulator will typically issue an error if the file doesn't exist or is in the wrong format.
        $readmemh(MEM_FILE, instr_rom);
        $display("Instruction Memory initialized from %s", MEM_FILE);
    end
    
    assign instr_o = valid_range ? instr_rom[word_idx] : 32'h00000013; // output instruction if is valid, otherwise NOP
    
endmodule