module IFMap_read_address_generator #(
    parameter ADDR_WIDTH = 16,
    parameter FILTER_SIZE_WIDTH = 4,
    parameter I_WIDTH,
    parameter STRIDE_WIDTH = 4,
    parameter IF_LENGTH = 12
)(
    input [ADDR_WIDTH-1:0] IF_start_addr,
    input [STRIDE_WIDTH -1:0] stride,
    input [FILTER_SIZE_WIDTH - 1:0] stride_step, // depends on IF size
    input [I_WIDTH - 1:0] i,

    output [ADDR_WIDTH-1:0] read_addr
);

    assign read_addr = (IF_start_addr + (stride_step * stride) + i) % ({ADDR_WIDTH{1'b0}} + IF_LENGTH);

endmodule
