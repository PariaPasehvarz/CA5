module main_controller #(parameter FILTER_ADDR_WIDTH) (
    input wire clk,
    input wire reset,                       //goes to IDLE state async, then idle emits an internal WRITE_REQ signal
    input wire start,
    input wire IF_empty,                    // Comes from IFMAP status (top)
    input wire filter_cannot_read,          // Comes from Cannot read filter (down)
    input wire [FILTER_ADDR_WIDTH - 1:0] filter_waddr,  // Comes from Filter write counter -> set number of bits
    input wire sp_valid,                    // Comes from start_ptr module (right)
    input wire stride_ended,
    input wire reading_empty,               // Comes from IFMAP status (top)
    input wire [1:0] stall,                 // Comes from write buffer controller
    input wire set_status,                  // Comes from IF read buffer controller
    input wire is_last_filter,              // Comes from is last item of last filter module (down)
    input wire error,
    input wire f_co,
    input wire go_next_stride,
    input wire ended,
    input wire go_next_filter,
    input wire psum_mode,
    input wire psum_buffer_valid,
    input wire can_read_psum,
    input wire psum_w_co,
    input interleaved_mode,
    input is_second_filter,
    
    output reg chip_en,
    output reg global_rst,     //internal reset for datapath
    output reg en_p_traverse,
    output reg ren,
    output reg ld_IF,
    output reg mult_en,
    output reg i_en,
    output reg ld_result,
    output reg rst_f_counter,
    output reg en_f_counter,
    output reg next_start,
    output reg next_stride,
    output reg done,
    output reg next_filter,
    output reg rst_stride,
    output reg stall_signal,
    output reg rst_stride_ended,
    output reg rst_is_last_filter,
    output reg rst_current_filter,
    output reg rst_p_valid,
    output reg make_empty,
    output reg first_time,
    output reg psum_buffer_ren,
    output reg next_psum_raddr,
    output reg next_psum_waddr,
    output reg rst_psum_raddr,
    output reg toggle_filter,
    output reg rst_toggle_filter
);

    localparam [3:0] 
        IDLE               = 4'd0,
        IDLE2              = 4'd1,
        START              = 4'd2,
        FIND_START_PTR     = 4'd3,
        PIPELINE_START     = 4'd4,
        PIPELINE_HALF_FULL = 4'd5,
        PIPELINE_FULL      = 4'd6,
        NEXT_PSUM_ADDR     = 4'd7,
        NEXT_IF            = 4'd8,
        UPDATE_START_PTR   = 4'd9,
        READ_REQ           = 4'd10,
        WRITE_REQ          = 4'd11,
        WAIT_FOR_WRITE     = 4'd12,
        STALL              = 4'd13,
        ADD_NEXT           = 4'd14;

    reg [3:0] current_state;
    reg [3:0] next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    wire freeze;
    assign freeze = reading_empty | filter_cannot_read | !sp_valid | (is_last_filter & go_next_filter);

    always @(*) begin
        next_state = current_state; //kepp in case of no else cluase in ifs
        
        case (current_state)
            IDLE: begin
                next_state = start?IDLE2:IDLE;
            end

            IDLE2: begin
                next_state = start ? IDLE2 : START;
            end

            START: begin
                next_state = ((IF_empty == 0) && (filter_waddr != 8'd0)) ? FIND_START_PTR : START;
            end

            FIND_START_PTR: begin
                next_state = sp_valid ? PIPELINE_START : FIND_START_PTR; 
            end

            PIPELINE_START: begin
                if (freeze)
                    next_state = PIPELINE_START;
                else 
                    next_state = PIPELINE_HALF_FULL;
            end

            PIPELINE_HALF_FULL: begin
                if (freeze)
                    next_state = PIPELINE_HALF_FULL;
                else
                    next_state = PIPELINE_FULL;
            end

            PIPELINE_FULL: begin
                if (psum_mode) begin
                    next_state = READ_REQ;
                end
                else if (is_last_filter & ~is_second_filter & go_next_filter) begin
                    next_state = NEXT_IF;
                end else if (freeze)
                    next_state = PIPELINE_FULL;
                else begin
                    next_state = f_co ? NEXT_PSUM_ADDR : PIPELINE_FULL;
                end
            end

            WRITE_REQ: begin
                next_state = WAIT_FOR_WRITE;
            end

            WAIT_FOR_WRITE: begin
                if (stall == 2'b00)
                    next_state = WAIT_FOR_WRITE;
                else if (stall == 2'b11)
                    next_state = STALL;
                else if (stall == 2'b10)
                    next_state = ADD_NEXT;
            end

            NEXT_IF: begin
                next_state = UPDATE_START_PTR;
            end

            STALL: begin
                // nothing
            end
            
            UPDATE_START_PTR: begin
                next_state = PIPELINE_FULL;
            end

            NEXT_PSUM_ADDR: begin
                if (psum_mode) 
                    next_state = READ_REQ;
                else if (psum_w_co)
                    next_state = STALL;
                else
                    next_state = PIPELINE_FULL;
            end

            READ_REQ: begin
                next_state = psum_buffer_valid ? WRITE_REQ : READ_REQ;
            end

            ADD_NEXT: begin
                next_state = READ_REQ;
            end

            default: next_state = IDLE;
        endcase
        if(error)
            next_state = STALL;
    end
    wire run_pipe;
    assign run_pipe = ~freeze & ~f_co;
    always @(*) begin
        {first_time, psum_buffer_ren,next_psum_raddr,next_psum_waddr, rst_psum_raddr} = 0;
        {toggle_filter, rst_toggle_filter} = 0;
        {en_f_counter,next_start, chip_en, global_rst,en_p_traverse,ren,ld_IF,mult_en,i_en,ld_result,rst_f_counter,next_stride,done,next_filter,
        rst_stride,stall_signal,rst_stride_ended,rst_is_last_filter,rst_current_filter,rst_p_valid,make_empty } = 0;

        case (current_state)

            IDLE: begin
                chip_en = 0;
            end

            IDLE2: begin
                chip_en = 1'b1;
                global_rst = 1'b1;
            end

            START: begin
                chip_en = 1'b1;
            end

            FIND_START_PTR: begin
                chip_en = 1'b1;
                en_p_traverse = !sp_valid;
            end

            PIPELINE_START: begin
                chip_en = 1'b1;
                ren = !freeze;
                ld_IF = !freeze;
                i_en = !freeze;
            end

            PIPELINE_HALF_FULL: begin
                chip_en = 1'b1;
                ld_IF = !freeze;
                mult_en = !freeze;
                ren = !freeze;
                i_en = !freeze;
            end

            PIPELINE_FULL: begin
                chip_en = 1'b1;
                ld_IF = run_pipe;
                i_en = run_pipe;
                ld_result = run_pipe;
                mult_en = run_pipe;
                ren = run_pipe;
                en_f_counter = run_pipe;
                next_stride = run_pipe & !stride_ended & !ended & (interleaved_mode ? (is_second_filter & go_next_stride): go_next_stride);
                next_filter = !freeze & (interleaved_mode ? (!is_second_filter & go_next_filter) : go_next_filter);
                rst_stride = !freeze & (interleaved_mode ? (!is_second_filter & go_next_filter) : go_next_filter);
                first_time = run_pipe ? 0 :first_time;
                rst_psum_raddr = psum_mode;
                toggle_filter = ~freeze & go_next_stride;
            end

            WRITE_REQ: begin
                chip_en = 1'b1;
                //next_stride = 1'b1;
                rst_f_counter = 1'b1;
                done = 1'b1;
                psum_buffer_ren = 1'b1;
            end

            WAIT_FOR_WRITE: begin
                chip_en = 1'b1;
                psum_buffer_ren = 1'b1;
            end

            NEXT_IF: begin
                chip_en = 1'b1;
                rst_is_last_filter = 1'b1;
                rst_current_filter = 1'b1;
                rst_p_valid = 1'b1;
                rst_stride_ended = 1'b1;
                make_empty = 1'b1;
                rst_stride = 1'b1;
                rst_toggle_filter = 1'b1;
            end

            STALL: begin
                chip_en = 1'b1;
                stall_signal = 1'b1;
            end
            UPDATE_START_PTR: begin
                next_start = 1'b1;
                chip_en = 1'b1;
            end

            NEXT_PSUM_ADDR: begin
                rst_f_counter = 1'b1;
                chip_en = 1'b1;
                first_time = 1'b1;
                next_psum_waddr = 1'b1;
                rst_stride_ended = !is_last_filter; //TODO: previously on wait_for_write, could cause problems, may need to be always 1
                next_psum_raddr = !psum_mode;
                rst_psum_raddr = psum_mode;
            end
            READ_REQ: begin
                psum_buffer_ren = can_read_psum;
                chip_en = 1'b1; 
            end
            ADD_NEXT: begin
                next_psum_raddr = 1'b1;
                chip_en = 1'b1;
            end
        endcase
    end

endmodule
