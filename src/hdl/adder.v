module adder #(
    parameter A_WIDTH = 8,
    parameter B_WIDTH = 8
)(
    input  signed [A_WIDTH-1:0] a,    
    input  signed [B_WIDTH-1:0] b,      
    output signed [B_WIDTH-1:0] sum    
);

    assign sum = a[B_WIDTH-1:0] + b;

endmodule
