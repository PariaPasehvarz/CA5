module SRAM
#(
    parameter ADDR_WIDTH = 4,    
    parameter DATA_WIDTH = 8,    
    parameter MEM_DEPTH = 16     
)
(
    input rst,
    input wire clk,      
    input wire chip_en,  
    input wire wen,      
    input wire ren,      
    input wire [ADDR_WIDTH-1:0] raddr,    
    input wire [ADDR_WIDTH-1:0] waddr,    
    input wire [DATA_WIDTH-1:0] din,     
    output reg [DATA_WIDTH-1:0] dout     
);

    reg [DATA_WIDTH-1:0] memory [0:MEM_DEPTH-1];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < MEM_DEPTH; i = i + 1) begin
                memory[i] <= 0;
            end
        end
        else if (chip_en && wen) begin          
            memory[waddr] <= din;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dout <= 0;
        end
        else if (chip_en && ren) begin         
            dout <= memory[raddr];
        end
    end
endmodule
