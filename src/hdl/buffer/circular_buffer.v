module circular_buffer #(
    parameter ROW_SIZE = 8,
    parameter COLUMNS = 32,
    parameter PAR_WRITE = 4,
    parameter PAR_READ = 4
)(
    input wire clk,
    input wire rst,
    input wire read_enable,
    input wire write_enable,
    input wire [(ROW_SIZE*PAR_WRITE)-1:0] din,
    output wire [(ROW_SIZE*PAR_READ)-1:0] dout,
    output wire valid,
    output wire ready,
    output wire full,
    output wire empty
);

    wire update_write_pointer;
    wire update_read_pointer;
    wire wen;

    circular_buffer_datapath #(
        .ROW_SIZE(ROW_SIZE),
        .COLUMNS(COLUMNS),
        .PAR_WRITE(PAR_WRITE),
        .PAR_READ(PAR_READ)
    ) datapath_inst (
        .clk(clk),
        .rst(rst),
        .wen(wen),
        .update_write_pointer(update_write_pointer),
        .update_read_pointer(update_read_pointer),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    circular_buffer_controller controller_inst (
        .clk(clk),
        .rst(rst),
        .full(full),
        .empty(empty),
        .read_enable(read_enable),
        .updateRP(update_read_pointer),
        .updateWP(update_write_pointer),
        .valid(valid),
        .ready(ready),
        .write_enable(write_enable),
        .wen(wen)
    );

endmodule 