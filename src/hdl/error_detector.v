module error_detector #(
    parameter ADDR_WIDTH = 10 // is clog2 of length of IFmap scratchpad
) (
    input make_empty,
    input set_status,
    input [ADDR_WIDTH-1:0] start_ptr,
    input [ADDR_WIDTH-1:0] end_ptr,
    input [ADDR_WIDTH-1:0] write_counter,
    output error
);
    assign error = make_empty && set_status && (write_counter >= start_ptr && write_counter <= end_ptr);
endmodule