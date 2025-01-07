module counter #(parameter WIDTH = 8) (
    input wire clk,
    input wire rst,
    input wire en,
    input wire [WIDTH-1: 0] Max_count,
    output reg [WIDTH-1:0] count
);

    assign done = (count == Max_count);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end else if (en) begin
            count <= count + 1;
        end
    end

endmodule