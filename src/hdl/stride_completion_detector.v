module stride_completion_detector #(
    parameter ADDR_WIDTH = 8
)(
    input  wire                   clk,
    input  wire                   rst,
    input wire ep_valid,
    input  wire [ADDR_WIDTH-1:0]  read_addr,
    input  wire [ADDR_WIDTH-1:0]  end_ptr,
    output reg                    stride_ended
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            stride_ended <= 1'b0;
        end
        else begin
            if(ep_valid)
                stride_ended <= stride_ended ? 1'b1: (end_ptr == read_addr);
        end
    end

endmodule