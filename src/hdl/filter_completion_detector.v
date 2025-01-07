module filter_completion_detector #(
    parameter ADDR_WIDTH = 8,
    //parameter FILTER_SIZE_WIDTH = 4,
    parameter FILTER_PAD_LENGTH = 12
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire [ADDR_WIDTH-1:0]  read_addr,
    //input  wire [FILTER_SIZE_WIDTH-1:0]  filter_size,
    //input  wire [ADDR_WIDTH-1:0]  write_counter,
    output reg                    is_last_filter
);

    /*always @(posedge clk or posedge rst) begin
        if (rst) begin
            is_last_filter <= 1'b0;
        end
        else begin
            is_last_filter <= is_last_filter ? 1'b1 : (write_counter-1 == read_addr);
        end
    end*/

    /*always @(posedge clk or posedge rst) begin
        if (rst) begin
            is_last_filter <= 1'b0;
        end
        else begin
            is_last_filter <= is_last_filter ? 1'b1 : (read_addr % filter_size == filter_size-1 & read_addr == write_counter);
        end
    end*/

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            is_last_filter <= 1'b0;
        end
        else begin
            is_last_filter <= is_last_filter ? 1'b1 : (read_addr == ({ADDR_WIDTH{1'b0}} + FILTER_PAD_LENGTH - 1));
        end
    end

endmodule