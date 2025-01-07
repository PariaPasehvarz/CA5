module filter_address_checker #(
    parameter ADDR_WIDTH = 8
)(
    input  wire [ADDR_WIDTH-1:0] write_addr,  
    input  wire [ADDR_WIDTH-1:0] read_addr,
    input  wire write_co,    
    output wire filter_can_not_read
);

    assign filter_can_not_read = write_co ? 1'b0 : (write_addr <= read_addr);

endmodule