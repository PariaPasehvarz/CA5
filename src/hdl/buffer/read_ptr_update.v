module read_ptr_update #(
    parameter COLUMNS = 32,
    parameter PAR_READ = 4
)(
    input wire updateRP,
    output reg [$clog2(COLUMNS)-1:0] read_ptr_out,
    input wire clk,
    input wire rst
);
    reg [$clog2(COLUMNS):0] next_read_ptr;
    always @(posedge clk) begin
        if (rst) begin
            read_ptr_out <= 0;
            next_read_ptr <= 0;
        end else if (updateRP) begin
            next_read_ptr = read_ptr_out + PAR_READ;
            read_ptr_out <= (next_read_ptr >= COLUMNS) ? 
                            (next_read_ptr - COLUMNS) : 
                            next_read_ptr;
        end
    end
endmodule
