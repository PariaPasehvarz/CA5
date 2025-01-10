module multiplier #(
    parameter A_WIDTH = 8,
    parameter B_WIDTH = 8
)(
    input  wire                    clk,
    input                         rst,    
    input  wire                    en,     
    input  signed [A_WIDTH-1:0]      a,       
    input  signed [B_WIDTH-1:0]      b,       
    output reg signed [A_WIDTH+B_WIDTH-1:0] prod   
);
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prod <= 0;
        end
        else if (en) begin
            prod <= a * b;             
        end
    end

endmodule