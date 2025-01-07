module i_counter #(
    parameter WIDTH = 5 
)(
    input wire clk,
    input wire rst,
    input wire count_en,
    input wire [WIDTH-1:0] filter_size,
    output reg [WIDTH-1:0] count,
    output reg go_next_stride
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            go_next_stride <= 0;
        end
        else if (count_en) begin
            count <= ((count + 1'b1) == filter_size) ? 0 : count + 1'b1;
            go_next_stride <= ((count + 2'd2) == filter_size) ? 1'b1 : 1'b0; //go next when i count hits its max
        end
    end

endmodule
/*
module i_counter #(
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
            inner_count = (inner_count == filter_size) ? 0 : inner_count + 1'b1;
        end
    end

    assign carry_out = (inner_count == filter_size) ? 1'b1 : 1'b0;
    assign count = carry_out ? 0 : inner_count;
endmodule
*/