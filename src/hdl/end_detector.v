module end_detector #(parameter ADDR_WIDTH = 8) (
    input wire [ADDR_WIDTH-1:0] end_ptr,
    input wire [ADDR_WIDTH-1:0] raddr,

    output wire ended
);

    assign ended = end_ptr == raddr;

endmodule