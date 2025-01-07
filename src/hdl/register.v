module register #(
    parameter WIDTH = 8  
)(
    input  wire             clk,    
    input  wire             rst,    
    input  wire             load,     
    input  wire [WIDTH-1:0] data_in,  
    output reg  [WIDTH-1:0] data_out  
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 0; 
        end
        else if (load) begin
            data_out <= data_in;
        end
    end

endmodule