module Data_Memory #(
    parameter XLEN = 32,
    parameter MEM_SIZE = 1024 // Size of memory in bytes
)(
    input clk_i,
    input rst_i,
    input mem_read_i, // from Control Unit
    input mem_write_i, // from Control Unit
    input [2:0] funct3_i, // from instruction, determines access size
    input [XLEN-1:0] addr_i, // alu result 
    input [XLEN-1:0] write_data_i, // alu src_output2
    output reg [XLEN-1:0] read_data_o
);

// Byte-addressable memory array
reg [7:0] mem [0:MEM_SIZE-1]; // 1 byte each

// Synchronous write logic
always @(posedge clk_i) begin
    if (mem_write_i) begin
        case (funct3_i)
            // sw (store word, funct3 = 3'b010)
            3'b010: begin
                mem[addr_i]   <= write_data_i[7:0];
                mem[addr_i+1] <= write_data_i[15:8];
                mem[addr_i+2] <= write_data_i[23:16];
                mem[addr_i+3] <= write_data_i[31:24];
            end
            // sh (store half-word, funct3 = 3'b001)
            3'b001: begin
                mem[addr_i]   <= write_data_i[7:0];
                mem[addr_i+1] <= write_data_i[15:8];
            end
            // sb (store byte, funct3 = 3'b000)
            3'b000: begin
                mem[addr_i]   <= write_data_i[7:0];
            end
        endcase
    end
end

// Asynchronous (combinational) read logic
always @(*) begin
    if (mem_read_i) begin
        case (funct3_i)
            // lw (load word, funct3 = 3'b010)
            3'b010: read_data_o = {mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i]};
            // lh (load half-word, sign-extended, funct3 = 3'b001)
            3'b001: read_data_o = {{16{mem[addr_i+1][7]}}, mem[addr_i+1], mem[addr_i]};
            // lb (load byte, sign-extended, funct3 = 3'b000)
            3'b000: read_data_o = {{24{mem[addr_i][7]}}, mem[addr_i]};
            // lhu (load half-word, unsigned, funct3 = 3'b101)
            3'b101: read_data_o = {{16{1'b0}}, mem[addr_i+1], mem[addr_i]};
            // lbu (load byte, unsigned, funct3 = 3'b100)
            3'b100: read_data_o = {{24{1'b0}}, mem[addr_i]};
            default: read_data_o = {XLEN{1'bx}}; // Return 'x' for unsupported types to aid debugging
        endcase
    end else begin
        read_data_o = {XLEN{1'bx}}; // Output 'x' when not reading to make bugs more visible
    end
end

// Memory initialization for simulation purposes
integer i;
initial begin
    for (i = 0; i < MEM_SIZE; i = i + 1) begin
        mem[i] = 8'h00;
    end
end

endmodule