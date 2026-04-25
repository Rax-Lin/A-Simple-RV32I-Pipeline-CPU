module Register_file#(
    parameter XLEN = 32,
    parameter REG_NUM = 32
)(
    input clk_i,
    input rst_i,
    // read port 1
    input [4:0] rs1_addr_i,
    output [XLEN-1:0] rs1_data_o,
    // read port 2
    input [4:0] rs2_addr_i,
    output [XLEN-1:0] rs2_data_o,
    // write port
    input we_i, // write enable
    input [4:0] rd_addr_i,
    input [XLEN-1:0] rd_data_i
);

endmodule   