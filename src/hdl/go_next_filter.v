module go_next_filter #(
    parameter ADDR_WIDTH = 8
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire ep_valid,
    input  wire [ADDR_WIDTH-1:0]  read_addr,
    input  wire [ADDR_WIDTH-1:0]  end_ptr,
    output reg                    go_next_filter
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            go_next_filter <= 1'b0;
        end
        else begin
            if(ep_valid)
                go_next_filter <= end_ptr == read_addr;
        end
    end

endmodule