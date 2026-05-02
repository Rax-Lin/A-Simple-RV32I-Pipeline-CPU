`timescale 1ns/1ps

module CPU_tb;

// Parameters
parameter CLK_PERIOD = 10; // 10ns clock period, 100MHz

// Signals
reg clk;
reg rst;

// Instantiate the CPU
CPU #(
    .XLEN(32),
    .MEM_FILE("testcase/program2.txt") // Specify which test program to run
) uut (
    .clk_i(clk),
    .rst_i(rst)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
end

// Reset and simulation control
initial begin
    $dumpfile("wave/cpu.vcd");
    $dumpvars(0, uut);

    rst = 1;
    #(CLK_PERIOD * 2);
    rst = 0;

    #(CLK_PERIOD * 100);

    // Call the verification task inside the register file module.
    // This is the recommended way to avoid hierarchical access issues in iverilog.
    uut.reg_file.print_regs();

    $display("Simulation finished.");
    $finish;
end

endmodule