module decode_status (
    input start_bit,
    input end_bit,
    output wire [1:0] next_status
);
    parameter EMPTY = 2'b00;
    parameter IF_START = 2'b01;
    parameter IF_END = 2'b10;
    parameter NONE = 2'b11;

    assign next_status = start_bit ? IF_START : (end_bit ? IF_END : NONE);
    

endmodule