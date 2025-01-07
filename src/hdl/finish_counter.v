module finish_counter #(
    parameter WIDTH = 5 
)(
    input wire clk,
    input wire rst,
    input wire count_en,
    input wire [WIDTH-1:0] filter_size,
    output wire [WIDTH-1:0] count, 
    output wire carry_out
);

    reg [WIDTH-1:0] inner_count;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            inner_count <= 0;
        end
        else if (count_en) begin
            if (!carry_out) begin
                inner_count <= inner_count + 1'b1;
            end
        end
    end

    assign carry_out = (inner_count == filter_size) ? 1'b1 : 1'b0;
    assign count = carry_out ? 0 : inner_count;
endmodule