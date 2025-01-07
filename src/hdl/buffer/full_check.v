module full_check #(
    parameter COLUMNS = 32,
    parameter PAR_WRITE = 4
)(
    input wire [$clog2(COLUMNS)-1:0] write_ptr,
    input wire [$clog2(COLUMNS)-1:0] read_ptr,
    output wire full
);
    wire [PAR_WRITE-1:0] matches;

    genvar i;
    generate
        for (i = 0; i < PAR_WRITE; i = i + 1) begin
            wire [$clog2(COLUMNS):0] next_write_ptr = write_ptr + i + 1; // this one must start from i+1 so that when WP == RP, is not assumed as full
            assign matches[i] = (next_write_ptr >= COLUMNS ? (next_write_ptr - COLUMNS) : next_write_ptr) == read_ptr;
        end
    endgenerate

    assign full = |matches;
endmodule
