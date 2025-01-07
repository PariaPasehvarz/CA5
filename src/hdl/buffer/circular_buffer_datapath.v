module circular_buffer_datapath #(
    parameter ROW_SIZE = 8,
    parameter COLUMNS = 32,
    parameter PAR_WRITE = 4,
    parameter PAR_READ = 4
)(
    input wire clk,
    input wire rst,
    input wire wen,
    input wire update_write_pointer,
    input wire update_read_pointer,
    input wire [(ROW_SIZE*PAR_WRITE)-1:0] din,
    output wire [(ROW_SIZE*PAR_READ)-1:0] dout,
    output wire full,
    output wire empty
);

    parameter INNER_COLUMNS = COLUMNS + 1;

    wire [(PAR_WRITE*$clog2(INNER_COLUMNS))-1:0] waddr;
    wire [(PAR_READ*$clog2(INNER_COLUMNS))-1:0] raddr;
    wire [$clog2(INNER_COLUMNS)-1:0] write_ptr_out, read_ptr_out;

    buffer #(
        .ROW_SIZE(ROW_SIZE),
        .COLUMNS(INNER_COLUMNS),
        .PAR_WRITE(PAR_WRITE),
        .PAR_READ(PAR_READ)
    ) buff (
        .clk(clk),
        .rst(rst),
        .wen(wen),
        .waddr(waddr),
        .din(din),
        .raddr(raddr),
        .dout(dout)
    );

    write_addr_gen #(
        .COLUMNS(INNER_COLUMNS),
        .PAR_WRITE(PAR_WRITE)
    ) w_addr_gen (
        .write_ptr(write_ptr_out),
        .waddr(waddr)
    );

    read_addr_gen #(
        .COLUMNS(INNER_COLUMNS),
        .PAR_READ(PAR_READ)
    ) r_addr_gen (
        .read_ptr(read_ptr_out),
        .raddr(raddr)
    );

    write_ptr_update #(
        .COLUMNS(INNER_COLUMNS),
        .PAR_WRITE(PAR_WRITE)
    ) wp_update (
        .updateWP(update_write_pointer),
        .write_ptr_out(write_ptr_out),
        .clk(clk),
        .rst(rst)
    );

    read_ptr_update #(
        .COLUMNS(INNER_COLUMNS),
        .PAR_READ(PAR_READ)
    ) rp_update (
        .updateRP(update_read_pointer),
        .read_ptr_out(read_ptr_out),
        .clk(clk),
        .rst(rst)
    );

    empty_check #(
        .COLUMNS(INNER_COLUMNS),
        .PAR_READ(PAR_READ)
    ) e_check (
        .write_ptr(write_ptr_out),
        .read_ptr(read_ptr_out),
        .empty(empty)
    );

    full_check #(
        .COLUMNS(INNER_COLUMNS),
        .PAR_WRITE(PAR_WRITE)
    ) f_check (
        .write_ptr(write_ptr_out),
        .read_ptr(read_ptr_out),
        .full(full)
    );
endmodule 