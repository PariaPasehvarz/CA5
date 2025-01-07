module stride_step_counter #(
    parameter WIDTH = 5 
)(
    input wire clk,           
    input wire rst,         
    input wire count_en,   //connected to next_stride  
    input wire [WIDTH-1:0] filter_size, //same as filter size
    output reg [WIDTH-1:0] count 
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end
        else if (count_en) begin
            if (count < filter_size) begin
                count <= count + 1'b1;
            end
        end
    end

endmodule