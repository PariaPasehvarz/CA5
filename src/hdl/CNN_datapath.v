module CNN_datapath #(
    parameter IFMAP_BUFFER_WIDTH = 8,
    parameter IFMAP_SPAD_WIDTH = 6,
    parameter FILTER_WIDTH = 8,
    parameter RESULT_BUFFER_WIDTH = 8,
    parameter MULT_WIDTH = IFMAP_SPAD_WIDTH + FILTER_WIDTH,
    parameter STRIDE_WIDTH = 3,
    parameter I_WIDTH = 5,
    parameter FILTER_SIZE_WIDTH = 3,
    parameter IF_ADDR_WIDTH = $clog2(IFMAP_SPAD_WIDTH),
    parameter FILTER_ADDR_WIDTH = $clog2(FILTER_WIDTH),
    parameter IF_PAD_LENGTH = 32,
    parameter FILTER_PAD_LENGTH = 32,
    parameter ADD_OUT_WIDTH = 32,

    //IF buffer
    parameter IF_BUFFER_COLUMNS = 32,
    parameter IF_BUFFER_PAR_WRITE = 1,
    //filter bufer
    parameter FILTER_BUFFER_COLUMNS = 32,
    parameter FILTER_BUFFER_PAR_WRITE = 1,
    //result buffer
    parameter RESULT_BUFFER_PAR_READ = 2,
    parameter RESULT_BUFFER_COLUMNS = 32
)(
    input wire clk,
    input wire chip_en,
    input wire global_rst,
    input wire en_p_traverse,
    input wire ren,
    input wire ld_IF,
    input wire mult_en,
    input wire i_en,
    input wire ld_result,
    input wire rst_f_counter,
    input wire en_f_counter,
    input wire next_stride,
    input wire done,
    input wire next_filter,
    input wire rst_stride,
    input wire rst_stride_ended,
    input wire rst_result,
    input wire rst_is_last_filter,
    input wire rst_current_filter,
    input wire rst_p_valid,
    input wire make_empty,
    input wire [STRIDE_WIDTH-1:0] stride,
    input wire [FILTER_SIZE_WIDTH-1:0] filter_size,
    input wire next_start,
    
    output IF_empty,
    output filter_cannot_read,
    output [FILTER_ADDR_WIDTH - 1:0] filter_waddr,
    output sp_valid,
    output f_co,
    output go_next_stride,
    output stride_ended,
    output reading_empty,
    output [1:0] stall,
    output set_status,
    output is_last_filter,
    output error,
    output ended,
    output go_next_filter,

    // buffers with outer modules:
    input [IFMAP_BUFFER_WIDTH-1:0] IFmap_buffer_in,
    input IFmap_buffer_write_enable,
    output IFmap_buffer_full,
    output IFmap_buffer_ready,

    input [FILTER_WIDTH-1:0] filter_buffer_in,
    input filter_buffer_write_enable,
    output filter_buffer_full,
    output filter_buffer_ready,

    output [RESULT_BUFFER_WIDTH-1:0] result_buffer_out,
    input result_buffer_read_enable,
    output result_buffer_valid,
    output result_buffer_empty
);
    //if section
    wire [IFMAP_BUFFER_WIDTH-1:0] IFmap_buffer_out;
    wire IFmap_buffer_valid;
    wire IFmap_buffer_read_enable;
    wire IFmap_pad_wen;
    wire IFmap_pad_counter_enable;
    wire IFMap_can_write;
    wire [1:0] next_status;
    wire [IF_ADDR_WIDTH-1:0] start_ptr, end_ptr;
    wire [IF_ADDR_WIDTH-1:0] IF_counter_out;
    wire [1:0] start_ptr_status, read_addr_status;
    wire [IF_ADDR_WIDTH-1:0] IF_raddr;
    wire update_end_ptr_out;
    wire [IFMAP_SPAD_WIDTH-1:0] IFmap_pad_out, IF_reg_out;
    wire [STRIDE_WIDTH-1:0] stride_step;
    wire [I_WIDTH-1:0] i_counter_out;
    wire ep_valid;

    if_read_buffer_controller if_read_buffer_controller_instance(
        .clk(clk),
        .rst(global_rst),
        .IFMap_can_write(IFMap_can_write),
        .buffer_valid(IFmap_buffer_valid),
        
        .buffer_read_enable(IFmap_buffer_read_enable),
        .pad_wen(IFmap_pad_wen),
        .pad_counter_enable(IFmap_pad_counter_enable),
        .set_status(set_status)
    );

    end_detector #(.ADDR_WIDTH(IF_ADDR_WIDTH)) end_detector_instance(
        .end_ptr(end_ptr),
        .raddr(IF_raddr),
        .ended(ended)
    );

    go_next_filter #(.ADDR_WIDTH(IF_ADDR_WIDTH)) go_next_filter_inst(.rst(global_rst),.clk(clk),.ep_valid(ep_valid),.read_addr(IF_raddr),.end_ptr(end_ptr), .go_next_filter(go_next_filter));

    wire IFmap_buffer_empty; // not used

    circular_buffer #(
        .ROW_SIZE(IFMAP_BUFFER_WIDTH),
        .COLUMNS(IF_BUFFER_COLUMNS),
        .PAR_WRITE(IF_BUFFER_PAR_WRITE),
        .PAR_READ(1)
    ) IFmap_buffer (
        .clk(clk),
        .rst(global_rst),
        .read_enable(IFmap_buffer_read_enable),
        .write_enable(IFmap_buffer_write_enable),
        .din(IFmap_buffer_in),

        .dout(IFmap_buffer_out),
        .valid(IFmap_buffer_valid),
        .ready(IFmap_buffer_ready),
        .full(IFmap_buffer_full),
        .empty(IFmap_buffer_empty)
    );

    decode_status DecodeStatus_instance(
        .start_bit(IFmap_buffer_out[IFMAP_BUFFER_WIDTH-1]),
        .end_bit(IFmap_buffer_out[IFMAP_BUFFER_WIDTH-2]),
        .next_status(next_status)
    );

    IFMap_status #(
        .LENGTH(IF_PAD_LENGTH)
    ) IFMapStatus_instance (
        .clk(clk),
        .rst(global_rst),
        .start_ptr(start_ptr),
        .end_ptr(end_ptr),
        .make_empty(make_empty),
        .set_status(set_status),
        .next_status(next_status),
        .status_write_addr(IF_counter_out),
        .read_addr(IF_raddr),

        .IFMap_can_write(IFMap_can_write),
        .reading_empty(reading_empty),
        .start_ptr_status(start_ptr_status),
        .read_addr_status(read_addr_status),
        .IF_empty(IF_empty)
    );

    update_ifmap_end_ptr update_ifmap_end_ptr_instance(
        .read_addr_status(read_addr_status),
        .update_end_ptr(update_end_ptr_out)
    );

    register_file #(
        .ADDR_WIDTH(IF_ADDR_WIDTH),
        .DATA_WIDTH(IFMAP_SPAD_WIDTH),
        .REG_COUNT(IF_PAD_LENGTH)
    ) IFmap_scratch_pad (
        .rst(global_rst),
        .clk(clk),
        .wen(IFmap_pad_wen),
        .raddr(IF_raddr),
        .waddr(IF_counter_out),
        .din(IFmap_buffer_out[IFMAP_SPAD_WIDTH-1:0]),
        .dout(IFmap_pad_out)
    );

    register #(
        .WIDTH(IFMAP_SPAD_WIDTH)
    ) IFmap_reg (
        .clk(clk),
        .rst(global_rst),
        .load(ld_IF),
        .data_in(IFmap_pad_out),
        .data_out(IF_reg_out)
    );

    IF_write_counter #(
        .MAX_COUNT(IF_PAD_LENGTH - 1), //TODO
        .WIDTH(IF_ADDR_WIDTH)
    ) IF_write_counter_instance (
        .clk(clk),
        .rst(global_rst),
        .count_en(IFmap_pad_counter_enable),
        .count(IF_counter_out)
    );

    IFMap_read_address_generator #(
        .ADDR_WIDTH(IF_ADDR_WIDTH),
        .FILTER_SIZE_WIDTH(FILTER_SIZE_WIDTH),
        .STRIDE_WIDTH(STRIDE_WIDTH),
        .I_WIDTH(I_WIDTH),
        .IF_LENGTH(IF_PAD_LENGTH)
    ) IFMapReadAddressGenerator_instance(
        .IF_start_addr(start_ptr),
        .stride(stride),
        .stride_step(stride_step),
        .i(i_counter_out),
        .read_addr(IF_raddr)
    );

    stride_completion_detector #(
        .ADDR_WIDTH(IF_ADDR_WIDTH)
    ) stride_completion_detector_instance (
        .clk(clk),
        .rst(global_rst | rst_stride_ended),
        .ep_valid(ep_valid),
        .read_addr(IF_raddr),
        .end_ptr(end_ptr),
        .stride_ended(stride_ended)
    );

    error_detector #(
        .ADDR_WIDTH(IF_ADDR_WIDTH)
    ) error_detector_instance (
        .make_empty(make_empty),
        .set_status(set_status),
        .start_ptr(start_ptr),
        .end_ptr(end_ptr),
        .write_counter(IF_counter_out),
        .error(error)
    );

    start_ptr #(
        .ADDR_WIDTH(IF_ADDR_WIDTH),
        .IF_LENGTH(IF_PAD_LENGTH)
    ) StartPtr_instance (
        .clk(clk),
        .rst(global_rst),
        .rst_p_valid(rst_p_valid),
        .en_p_traverse(en_p_traverse),
        .next_start(next_start),
        .end_ptr(end_ptr),

        .start_ptr_status(start_ptr_status),
        .sp_valid(sp_valid),
        .start_ptr(start_ptr)
    );

    end_ptr #(
        .ADDR_WIDTH(IF_ADDR_WIDTH)
    ) EndPtr_instance (
        .rst(global_rst),
        .rst_p_valid(rst_p_valid),
        .update_end_ptr(update_end_ptr_out),
        .end_ptr_in(IF_raddr),
        .ep_valid(ep_valid),
        .end_ptr(end_ptr)
    );

    stride_step_counter #( 
        .WIDTH(STRIDE_WIDTH)
    ) stride_step_counter_instance (
        .clk(clk),
        .rst(global_rst | rst_stride),
        .count_en(next_stride),
        .filter_size(filter_size),
        .count(stride_step)
    );
    i_counter #( 
        .WIDTH(I_WIDTH)
    ) i_counter_instance (
        .clk(clk),
        .rst(global_rst),
        .count_en(i_en),
        .filter_size(filter_size),
        .count(i_counter_out),
        .go_next_stride(go_next_stride)
    );

    // finish counter parameter is same as i counter
    wire [I_WIDTH-1 : 0] finish_counter_out; //not used
    finish_counter #( 
        .WIDTH(I_WIDTH)
    ) finish_counter_instance (
        .clk(clk),
        .rst(global_rst | rst_f_counter),
        .count_en(en_f_counter),
        .filter_size(filter_size),
        .count(finish_counter_out),
        .carry_out(f_co)
    );

    //filter section
    wire filter_buffer_read_enable;
    wire filter_pad_wen;
    wire filter_pad_counter_enable;
    wire filter_counter_co;
    wire filter_buffer_valid;
    wire [FILTER_WIDTH-1:0] filter_buffer_out,filter_sram_out;
    wire [FILTER_ADDR_WIDTH-1:0] filter_raddr, current_filter_start_addr;

    filter_read_buffer_controller filter_read_buffer_controller_instance(
        .clk(clk),
        .rst(global_rst),
        .buffer_valid(filter_buffer_valid),
        .co(filter_counter_co),
        .chip_en(chip_en),
        
        .buffer_read_enable(filter_buffer_read_enable),
        .pad_wen(filter_pad_wen),
        .pad_counter_enable(filter_pad_counter_enable)
    );
    wire filter_buffer_empty; //not used
    circular_buffer #(
        .ROW_SIZE(FILTER_WIDTH),
        .COLUMNS(FILTER_BUFFER_COLUMNS),
        .PAR_WRITE(FILTER_BUFFER_PAR_WRITE),
        .PAR_READ(1)
    ) Filter_buffer (
        .clk(clk),
        .rst(global_rst),
        .read_enable(filter_buffer_read_enable),
        .write_enable(filter_buffer_write_enable),
        .din(filter_buffer_in),
        .dout(filter_buffer_out),
        .valid(filter_buffer_valid),
        .ready(filter_buffer_ready),
        .full(filter_buffer_full),
        .empty(filter_buffer_empty)
    );

    SRAM  #(
        .ADDR_WIDTH(FILTER_ADDR_WIDTH),
        .DATA_WIDTH(FILTER_WIDTH),
        .MEM_DEPTH(FILTER_PAD_LENGTH)
    ) filter_sram (
        .rst(global_rst),
        .clk(clk),
        .chip_en(chip_en),
        .wen(filter_pad_wen),
        .ren(ren),
        .raddr(filter_raddr),
        .waddr(filter_waddr),
        .din(filter_buffer_out),
        .dout(filter_sram_out)
    );

    filter_write_counter #(
        .WIDTH(FILTER_ADDR_WIDTH),
        .MAX(FILTER_PAD_LENGTH - 1) //TODO
    ) filter_write_counter_instance (
        .clk(clk),
        .rst(global_rst),
        .count_en(filter_pad_counter_enable),
        .count(filter_waddr),
        .carry_out(filter_counter_co)
    );

    filter_read_address_generator #(
        .ADDR_WIDTH(FILTER_ADDR_WIDTH),
        .I_WIDTH(I_WIDTH)
    ) FilterReadAddressGenerator_instance (
        .current_filter_start_addr(current_filter_start_addr),
        .i(i_counter_out),
        .read_addr(filter_raddr)
    );

    current_filter_start #(
        .ADDR_WIDTH(FILTER_ADDR_WIDTH),
        .MAX_FILTER_SIZE(FILTER_SIZE_WIDTH)
    ) CurrentFilterStart_instance (
        .clk(clk),
        .rst(global_rst | rst_current_filter),
        .next_filter(next_filter),
        .filter_size(filter_size),
        .current_filter_start_addr(current_filter_start_addr)
    );

    filter_address_checker #(
        .ADDR_WIDTH(FILTER_ADDR_WIDTH)
    ) filter_address_checker_instance (
        .write_addr(filter_waddr),
        .read_addr(filter_raddr),
        .write_co(filter_counter_co),
        .filter_can_not_read(filter_cannot_read)
    );

    filter_completion_detector #(
        .ADDR_WIDTH(FILTER_ADDR_WIDTH),
        //.FILTER_SIZE_WIDTH(FILTER_SIZE_WIDTH)
        .FILTER_PAD_LENGTH(FILTER_PAD_LENGTH)
    ) filter_completion_detector_instance (
        .clk(clk),
        .rst(global_rst | rst_is_last_filter),
        .read_addr(filter_raddr),
        //.filter_size(filter_size),
        //.write_counter(filter_waddr),
        .is_last_filter(is_last_filter)
    );

    //write section
    wire result_buffer_write_enable,result_buffer_ready;
    wire [MULT_WIDTH-1:0] mult_out;
    wire [ADD_OUT_WIDTH-1:0] add_out;
    wire [RESULT_BUFFER_WIDTH-1:0] result_reg_out;
    write_buffer_controller write_buffer_controller_instance(
        .clk(clk),
        .rst(global_rst),
        .done(done),
        .buffer_ready(result_buffer_ready),
        .buffer_write_en(result_buffer_write_enable),
        .stall(stall)
    );

    wire result_buffer_full;     //not used
    circular_buffer #(
        .ROW_SIZE(RESULT_BUFFER_WIDTH),
        .COLUMNS(RESULT_BUFFER_COLUMNS),
        .PAR_WRITE(1),
        .PAR_READ(RESULT_BUFFER_PAR_READ)
    ) Result_buffer(
        .clk(clk),
        .rst(global_rst),
        .read_enable(result_buffer_read_enable),
        .write_enable(result_buffer_write_enable),
        .din(result_reg_out),
        .dout(result_buffer_out),
        .valid(result_buffer_valid),
        .ready(result_buffer_ready),
        .full(result_buffer_full),
        .empty(result_buffer_empty)
    );

    register  #(
        .WIDTH(RESULT_BUFFER_WIDTH)
    )ResultRegister(
        .clk(clk),
        .rst(global_rst | rst_result),
        .load(ld_result),
        .data_in(add_out),
        .data_out(result_reg_out)
    );

    adder  #(
        .A_WIDTH(MULT_WIDTH),
        .B_WIDTH(RESULT_BUFFER_WIDTH)
    ) adder_instance(
        .a(mult_out),
        .b(result_reg_out),
        .sum(add_out)
    );

    multiplier #(
        .A_WIDTH(FILTER_WIDTH),
        .B_WIDTH(IFMAP_SPAD_WIDTH)
    ) reg_multiplier_instance (
        .clk(clk),
        .rst(global_rst),
        .en(mult_en),
        .a(filter_sram_out),
        .b(IF_reg_out),
        .prod(mult_out)
    );


endmodule