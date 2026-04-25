module Instr_MEM#(
    parameter XLEN      = 32,
    parameter DEPTH     = 1024,                // word number of instruction memory
    parameter BASE_ADDR = 32'h0000_0000,
    parameter MEM_FILE  = "testcase/program.txt"
)(
    input clk_i,
    input rst_i, // for future usage
    // Prgoram Counter
    input [XLEN-1:0] PC_i,
    output [XLEN-1:0] instr_o
);

reg [XLEN-1:0] instr_rom [0:DEPTH-1];
reg [XLEN-1:0] probe;
wire [XLEN-1:0] byte_off, word_idx;
wire valid_range;

assign byte_off = PC_i - BASE_ADDR;
assign word_idx = byte_off[XLEN-1:2]; // word aligned
assign valid_range = (byte_off[1:0] == 0) && (word_idx < DEPTH); // check if the address is word aligned and within the memory range

// instruction initialize
initial begin
    for (i = 0; i < DEPTH; i = i + 1) begin
        instr_rom[i] = 32'h00000013;
    end
    fd = $fopen(MEM_FILE, "r");
    if (fd == 0) begin
        $fatal(1, "Instr_MEM: cannot open file: %s", MEM_FILE);
    end
    rc = $fscanf(fd, "%h", probe);
    if (rc != 1) begin
        $fatal(1, "Instr_MEM: file is empty or not hex format: %s", MEM_FILE);
    end
    $fclose(fd);
    $readmemh(MEM_FILE, instr_rom); // for the simulation test
    $display("Instruction Memory initialized from %s", MEM_FILE);
end

assign instr_o = valid_range ? instr_rom[word_idx] : 32'h00000013; // output instruction if is valid

endmodule