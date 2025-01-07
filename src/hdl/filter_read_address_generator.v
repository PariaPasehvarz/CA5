module filter_read_address_generator #(parameter ADDR_WIDTH = 16,parameter I_WIDTH = 4)(
    input [ADDR_WIDTH-1:0] current_filter_start_addr,
    input [I_WIDTH-1:0] i,

    output [ADDR_WIDTH-1:0] read_addr
);
    assign read_addr = current_filter_start_addr + i;
endmodule
