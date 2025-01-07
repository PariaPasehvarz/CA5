module IF_write_counter #(
    parameter MAX_COUNT = 10,  
    parameter WIDTH = 5
)(
    input wire clk,           
    input wire rst,         
    input wire count_en,    
    output reg [WIDTH-1:0] count    
);


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end
        else if (count_en) begin
            if (count == MAX_COUNT) begin
                count <= 0;  
            end
            else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule