module Forwarding_Unit(
    // Source register addresses in EX stage
    input [4:0] exe_rs1_i,
    input [4:0] exe_rs2_i,

    // Destination register addresses from later stages
    input [4:0] mem_rd_i,
    input [4:0] wb_rd_i,
    input mem_reg_we_i,
    input wb_reg_we_i,

    // Forwarding select for EX operand muxes
    // 2'b00: original EX rs data
    // 2'b01: forward from MEM stage
    // 2'b10: forward from WB stage
    output reg [1:0] forwardA_o,
    output reg [1:0] forwardB_o
);

localparam [1:0] FWD_NONE = 2'b00;
localparam [1:0] FWD_WB   = 2'b10;
localparam [1:0] FWD_MEM  = 2'b01;

always @(*) begin

    // EX rs1 forwarding
    if (mem_reg_we_i && (mem_rd_i != 0) && (mem_rd_i == exe_rs1_i))
        forwardA_o = FWD_MEM;
    else if (wb_reg_we_i && (wb_rd_i != 0) && (wb_rd_i == exe_rs1_i))
        forwardA_o = FWD_WB;
    else forwardA_o = FWD_NONE;

    // EX rs2 forwarding
    if (mem_reg_we_i && (mem_rd_i != 0) && (mem_rd_i == exe_rs2_i))
        forwardB_o = FWD_MEM;
    else if (wb_reg_we_i && (wb_rd_i != 0) && (wb_rd_i == exe_rs2_i))
        forwardB_o = FWD_WB;
    else forwardB_o = FWD_NONE;
end

endmodule
