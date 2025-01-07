module can_read_psum_detector #(parameter ADDR_WIDTH = 8) (
    input [ADDR_WIDTH - 1 : 0] raddr,
    input [ADDR_WIDTH - 1 : 0] waddr,
    output can_read_psum
);

    assign can_read_psum = raddr < waddr;

endmodule