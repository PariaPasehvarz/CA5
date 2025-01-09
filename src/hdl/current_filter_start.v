module current_filter_start #(parameter ADDR_WIDTH = 16, parameter MAX_FILTER_SIZE = 4)(
    input clk,
    input rst,
    input next_filter,
    input [MAX_FILTER_SIZE-1:0] filter_size,
    input interleaved_mode,
    output reg [ADDR_WIDTH-1:0] current_filter_start_addr
);
    always @(posedge next_filter or posedge rst) begin
        if (rst) begin
            current_filter_start_addr <= 0;
        end else begin
            if (next_filter) begin
                current_filter_start_addr <= current_filter_start_addr + (interleaved_mode ? 2 * filter_size: filter_size);
            end
        end
    end
endmodule
