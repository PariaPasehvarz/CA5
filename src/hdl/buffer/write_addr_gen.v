module write_addr_gen #(
    parameter COLUMNS = 32,
    parameter PAR_WRITE = 4
)(
    input wire [$clog2(COLUMNS)-1:0] write_ptr,
    output wire [(PAR_WRITE*$clog2(COLUMNS))-1:0] waddr
);

    genvar i;
    generate
        for (i = 0; i < PAR_WRITE; i = i + 1) begin : gen_waddr
            wire [$clog2(COLUMNS):0] next_addr = write_ptr + i; // again need 1 extra bit for overflow handling
            assign waddr[(i+1)*$clog2(COLUMNS)-1 : i*$clog2(COLUMNS)] = 
                (next_addr >= COLUMNS) ? (next_addr - COLUMNS) : next_addr;
        end
    endgenerate

endmodule
