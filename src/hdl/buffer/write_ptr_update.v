module write_ptr_update #(
    parameter COLUMNS = 32,
    parameter PAR_WRITE = 4
)(
    input wire updateWP,
    output reg [$clog2(COLUMNS)-1:0] write_ptr_out,
    input wire clk,
    input wire rst
);
    reg [$clog2(COLUMNS):0] next_write_ptr; //need one extra bit to handle overflow

    always @(posedge clk) begin
        if (rst) begin
            write_ptr_out <= 0;
            next_write_ptr <= 0;
        end else if (updateWP) begin
            next_write_ptr = write_ptr_out + PAR_WRITE;
            write_ptr_out <= (next_write_ptr >= COLUMNS) ? 
                             (next_write_ptr - COLUMNS) : 
                             next_write_ptr;
        end
    end

endmodule
