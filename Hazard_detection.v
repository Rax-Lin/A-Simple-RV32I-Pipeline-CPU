module Hazard_Detection(
    // Source register addresses in ID stage
    input [4:0] id_rs1_i,
    input [4:0] id_rs2_i,

    // Destination register address from EX stage
    input [4:0] exe_rd_i,
    input exe_reg_we_i,
    input exe_mem_read_i,

    // Stall signal to pause the pipeline
    output reg stall_o
);

always @(*) begin
    // A load-use data hazard occurs when an instruction in the ID stage
    // depends on the result of a load instruction currently in the EX stage.
    // The data will not be ready in time even with forwarding, so we must stall.
    if (exe_mem_read_i && (exe_rd_i != 5'b0) && (exe_rd_i == id_rs1_i || exe_rd_i == id_rs2_i)) begin
        stall_o = 1'b1; // Stall the pipeline
    end else begin
        stall_o = 1'b0; // No hazard, no stall
    end
end

endmodule