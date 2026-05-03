module Program_Counter#(
    parameter XLEN = 32
)
(
    input clk_i,
    input rst_i,
    input stall_i,
    input [XLEN-1:0] PC_i,
    output [XLEN-1:0] PC_o
);
// haven't consider branch prediction.
reg [XLEN-1:0] PC_temp;
always @(posedge clk_i)begin
    if(rst_i)begin
        PC_temp <= 0;
    end
    else if(stall_i)begin
        PC_temp <= PC_temp; // do not go to the next instruction(pc = pc + 4) when stall
    end
    else begin
        PC_temp <= PC_i;  
    end
end

assign PC_o = PC_temp;

endmodule