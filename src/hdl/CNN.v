module CNN #(
    parameter IFMAP_BUFFER_WIDTH = 8,       // We have it
    parameter IF_ADDR_WIDTH = 8,            // Calculate inside testbench: = $clog2(IFMAP_BUFFER_WIDTH - 2),
    parameter IF_BUFFER_COLUMNS = 8,        // We have it -> Num of rows
    parameter IF_BUFFER_PAR_WRITE = 8,      
    parameter IF_PAD_LENGTH = 8,            // Num of rows in scratchpad

    parameter FILTER_BUFFER_WIDTH = 8,      // We have it
    parameter FILTER_SIZE_WIDTH = 8,        // We have it
    parameter FILTER_ADDR_WIDTH = 8,        // Calculate inside testbench: = $clog2(FILTER_BUFFER_WIDTH)
    parameter FILTER_PAD_LENGTH = 8,        // Num of rows in scratchpad
    parameter FILTER_BUFFER_COLUMNS = 8,    // We have it -> Num of rows
    parameter FILTER_BUFFER_PAR_WRITE = 8,

    parameter RESULT_BUFFER_WIDTH = 8,      // FILTER_BUFFER_WIDTH
    parameter RESULT_BUFFER_PAR_READ = 8,
    parameter RESULT_BUFFER_COLUMNS = 8,    // FILTER_BUFFER_COLUMNS -> Num of rows

    parameter ADD_OUT_WIDTH = 8,            // RESULT_BUFFER_WIDTH
    parameter STRIDE_WIDTH = 8,             // We have it 
    parameter MULT_WIDTH = 8,               // RESULT_BUFFER_WIDTH
    parameter I_WIDTH = 8                   // This is filter size, set it in testbench
    
) (
    input clk,
    input reset,
    input start,
    input [STRIDE_WIDTH-1:0] stride,
    input [FILTER_SIZE_WIDTH-1:0] filter_size,

    input [IFMAP_BUFFER_WIDTH - 1 : 0] IFmap_buffer_in,
    input IFmap_buffer_write_enable,

    input [FILTER_BUFFER_WIDTH - 1:0] filter_buffer_in,
    input filter_buffer_write_enable,

    output IFmap_buffer_full,
    output IFmap_buffer_ready,

    output filter_buffer_full,
    output filter_buffer_ready,

    output stall_signal,
    output [RESULT_BUFFER_WIDTH-1:0] result_buffer_out,
    output result_buffer_empty,
    output result_buffer_valid,
    input result_buffer_read_enable
);

    wire IF_empty, filter_cannot_read ,sp_valid, ended;
    wire stride_ended,reading_empty,set_status,is_last_filter,error;
    wire [1:0] stall;
    wire chip_en, global_rst,en_p_traverse, ren,ld_result, ld_IF;
    wire next_stride, done,next_filter, rst_stride,rst_stride_ended;
    wire rst_result, rst_is_last_filter,rst_current_filter,rst_p_valid,make_empty;
    wire f_co,rst_f_counter,en_f_counter,go_next_stride;
    wire [FILTER_ADDR_WIDTH-1:0] filter_waddr;
    wire next_start, go_next_filter;
    main_controller #(.FILTER_ADDR_WIDTH(FILTER_ADDR_WIDTH)) main_controller_instance(
        .clk(clk),
        .reset(reset),
        .start(start),
        .IF_empty(IF_empty),
        .filter_cannot_read(filter_cannot_read),
        .filter_waddr(filter_waddr),
        .sp_valid(sp_valid),
        .stride_ended(stride_ended),
        .reading_empty(reading_empty),
        .stall(stall),
        .set_status(set_status),
        .is_last_filter(is_last_filter),
        .error(error),
        .f_co(f_co),
        .go_next_stride(go_next_stride),
        .ended(ended),
        .go_next_filter(go_next_filter),

        .chip_en(chip_en),
        .global_rst(global_rst),
        .en_p_traverse(en_p_traverse),
        .ren(ren),
        .ld_IF(ld_IF),
        .mult_en(mult_en),
        .i_en(i_en),
        .en_f_counter(en_f_counter),
        .rst_f_counter(rst_f_counter),
        .ld_result(ld_result),
        .next_stride(next_stride),
        .done(done),
        .next_filter(next_filter),
        .rst_stride(rst_stride),
        .stall_signal(stall_signal),
        .rst_stride_ended(rst_stride_ended),
        .rst_result(rst_result),
        .rst_is_last_filter(rst_is_last_filter),
        .rst_current_filter(rst_current_filter),
        .rst_p_valid(rst_p_valid),
        .make_empty(make_empty),
        .next_start(next_start)
    );

    CNN_datapath #(
    .ADD_OUT_WIDTH(ADD_OUT_WIDTH),
    .IFMAP_BUFFER_WIDTH(IFMAP_BUFFER_WIDTH),
    .IFMAP_SPAD_WIDTH(IFMAP_BUFFER_WIDTH - 2),
    .FILTER_WIDTH(FILTER_BUFFER_WIDTH),
    .RESULT_BUFFER_WIDTH(RESULT_BUFFER_WIDTH),
    .MULT_WIDTH(MULT_WIDTH),
    .STRIDE_WIDTH(STRIDE_WIDTH),
    .I_WIDTH(I_WIDTH),
    .FILTER_SIZE_WIDTH(FILTER_SIZE_WIDTH),
    .IF_ADDR_WIDTH(IF_ADDR_WIDTH),              // = $clog2(IFMAP_SPAD_WIDTH),
    .FILTER_ADDR_WIDTH(FILTER_ADDR_WIDTH),      // = $clog2(FILTER_WIDTH),
    .IF_PAD_LENGTH(IF_PAD_LENGTH),
    .FILTER_PAD_LENGTH(FILTER_PAD_LENGTH),

    //IF buffer
    .IF_BUFFER_COLUMNS(IF_BUFFER_COLUMNS),
    .IF_BUFFER_PAR_WRITE(IF_BUFFER_PAR_WRITE),
    //filter bufer
    .FILTER_BUFFER_COLUMNS(FILTER_BUFFER_COLUMNS),
    .FILTER_BUFFER_PAR_WRITE(FILTER_BUFFER_PAR_WRITE),
    //result buffer
    .RESULT_BUFFER_PAR_READ(RESULT_BUFFER_PAR_READ),
    .RESULT_BUFFER_COLUMNS(RESULT_BUFFER_COLUMNS)
) cnn_datapath(
    //inputs from main controller:
    .clk(clk),
    .chip_en(chip_en),
    .global_rst(global_rst),
    .en_p_traverse(en_p_traverse),
    .ren(ren),
    .ld_IF(ld_IF),
    .mult_en(mult_en),
    .i_en(i_en),
    .ld_result(ld_result),
    .rst_f_counter(rst_f_counter),
    .en_f_counter(en_f_counter),
    .next_stride(next_stride),
    .done(done),
    .next_filter(next_filter),
    .rst_stride(rst_stride),
    .rst_stride_ended(rst_stride_ended),
    .rst_result(rst_result),
    .rst_is_last_filter(rst_is_last_filter),
    .rst_current_filter(rst_current_filter),
    .rst_p_valid(rst_p_valid),
    .make_empty(make_empty),
    .stride(stride),
    .filter_size(filter_size),
    .next_start(next_start),

    //outputs to be used in main controller:
    .IF_empty(IF_empty),
    .filter_cannot_read(filter_cannot_read),
    .filter_waddr(filter_waddr),
    .sp_valid(sp_valid),
    .f_co(f_co),
    .go_next_stride(go_next_stride),
    .stride_ended(stride_ended),
    .reading_empty(reading_empty),
    .stall(stall),
    .set_status(set_status),
    .is_last_filter(is_last_filter),
    .error(error),
    .ended(ended),
    .go_next_filter(go_next_filter),


    // buffers with outer modules:
    .IFmap_buffer_in(IFmap_buffer_in),
    .IFmap_buffer_write_enable(IFmap_buffer_write_enable),
    .IFmap_buffer_full(IFmap_buffer_full),
    .IFmap_buffer_ready(IFmap_buffer_ready),

    .filter_buffer_in(filter_buffer_in),
    .filter_buffer_write_enable(filter_buffer_write_enable),
    .filter_buffer_full(filter_buffer_full),
    .filter_buffer_ready(filter_buffer_ready),

    .result_buffer_out(result_buffer_out),
    .result_buffer_read_enable(result_buffer_read_enable),
    .result_buffer_valid(result_buffer_valid),
    .result_buffer_empty(result_buffer_empty)
);
endmodule