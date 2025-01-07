module read_addr_gen #(
    parameter COLUMNS = 32,
    parameter PAR_READ = 4
)(
    input wire [$clog2(COLUMNS)-1:0] read_ptr,
    output wire [(PAR_READ*$clog2(COLUMNS))-1:0] raddr
);

    genvar i;
    generate
        for (i = 0; i < PAR_READ; i = i + 1) begin : gen_raddr
            wire [$clog2(COLUMNS):0] next_addr = read_ptr + i;
            assign raddr[(i+1)*$clog2(COLUMNS)-1 : i*$clog2(COLUMNS)] = 
                (next_addr >= COLUMNS) ? (next_addr - COLUMNS) : next_addr;
        end
    endgenerate
endmodule
