module psum_address_generator_counter #(parameter WIDTH = 8, parameter MAX_COUNT = 255) (
    input wire clk,
    input wire rst,
    input wire en,
    output reg [WIDTH-1: 0] count
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end else if (en && count < MAX_COUNT) begin
            count <= count + 1;
        end
    end

endmodule