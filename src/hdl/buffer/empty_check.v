module empty_check #(
    parameter COLUMNS = 32,
    parameter PAR_READ = 4
)(
    input wire [$clog2(COLUMNS)-1:0] write_ptr,
    input wire [$clog2(COLUMNS)-1:0] read_ptr,
    output wire empty
);
    wire [PAR_READ-1:0] matches;

    genvar i;
    generate
        for (i = 0; i < PAR_READ; i = i + 1) begin
            wire [$clog2(COLUMNS):0] next_read_ptr = read_ptr + i;
            assign matches[i] = (next_read_ptr >= COLUMNS ? (next_read_ptr - COLUMNS) : next_read_ptr) == write_ptr;
        end
    endgenerate

    assign empty = |matches;
endmodule
