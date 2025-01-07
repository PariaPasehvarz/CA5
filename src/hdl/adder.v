module adder #(
    parameter A_WIDTH = 8,
    parameter B_WIDTH = 8
)(
    input  wire [A_WIDTH-1:0] a,    
    input  wire [B_WIDTH-1:0] b,      
    output wire [B_WIDTH-1:0] sum    
);

    assign sum = a[B_WIDTH-1:0] + b;

endmodule
