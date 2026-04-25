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

reg [XLEN-1:0] reg_file [0:REG_NUM-1]; // 32 registers, each 32 bits wide
integer i;

// keep x0 = 0
assign rs1_data_o = (rs1_addr_i != 0) ? reg_file[rs1_addr_i] : 0; // x0 is always 0
assign rs2_data_o = (rs2_addr_i != 0) ? reg_file[rs2_addr_i] : 0; // x0 is always 0

always @(posedge clk_i) begin
    if (rst_i) begin
        // reset all registers to 0
        for (i = 0; i < REG_NUM; i = i + 1) begin
            reg_file[i] <= 0;
        end
    end else if (we_i && rd_addr_i != 0) begin
        // write data to register file, x0 is read-only
        reg_file[rd_addr_i] <= rd_data_i;
    end
end

endmodule   