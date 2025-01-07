module register_file
#(
    parameter ADDR_WIDTH = 5,    
    parameter DATA_WIDTH = 8,   
    parameter REG_COUNT = 32 
)
(
    input  wire                  rst,
    input  wire                  clk,     
    input  wire                  wen,     
    input  wire [ADDR_WIDTH-1:0] raddr,   
    input  wire [ADDR_WIDTH-1:0] waddr,   
    input  wire [DATA_WIDTH-1:0] din,      
    output reg  [DATA_WIDTH-1:0] dout      
);

    reg [DATA_WIDTH-1:0] registers [0:REG_COUNT-1];
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < REG_COUNT; i = i + 1) begin
                registers[i] <= 0;
            end
        end
        else if (wen) begin
            registers[waddr] <= din;
        end
    end

    always @(*) begin
        dout = registers[raddr];
    end

endmodule
