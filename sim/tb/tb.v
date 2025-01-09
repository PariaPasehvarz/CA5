// `define CLK 10
// `define CLK_HALF 5
// module tb();

//     // Parameters from the image
//     parameter IFMAP_BUFFER_WIDTH = 18;    // ifmap_width
//     parameter FILTER_BUFFER_WIDTH = 16;   // filter_width
//     parameter FILTER_SIZE_WIDTH = 5;      // Same as filter_width for storage
//     parameter STRIDE_WIDTH = 5;
//     parameter IF_BUFFER_COLUMNS = 12;
//     parameter FILTER_BUFFER_COLUMNS = 16;

//     // Calculated parameters
//     parameter IF_ADDR_WIDTH = $clog2(IFMAP_BUFFER_WIDTH - 2);          // $clog2(IFMAP_BUFFER_WIDTH - 2)
//     parameter FILTER_ADDR_WIDTH = $clog2(FILTER_BUFFER_WIDTH);         // $clog2(FILTER_BUFFER_WIDTH)
    
//     // Other parameters matching top module
//     parameter IF_BUFFER_PAR_WRITE = 1;
//     parameter IF_PAD_LENGTH = 12;
//     parameter FILTER_PAD_LENGTH = 16;
//     parameter FILTER_BUFFER_PAR_WRITE = 1;

//     parameter RESULT_BUFFER_WIDTH = FILTER_BUFFER_WIDTH;
//     parameter RESULT_BUFFER_PAR_READ = 1;
//     parameter RESULT_BUFFER_COLUMNS = 64;
    
//     parameter ADD_OUT_WIDTH = RESULT_BUFFER_WIDTH;
//     parameter MULT_WIDTH = IFMAP_BUFFER_WIDTH - 2 + FILTER_BUFFER_WIDTH;
//     parameter I_WIDTH = 5;

//     parameter PSUM_SPAD_WIDTH = 16;
//     parameter PSUM_PAD_LENGTH = 17; //from test cases
//     parameter PSUM_ADDR_WIDTH = $clog2(PSUM_PAD_LENGTH);

//     parameter PSUM_BUFFER_WIDTH = RESULT_BUFFER_WIDTH;
//     parameter PSUM_BUFFER_COLUMNS = 16;

//     // Testbench signals
//     reg clk;
//     reg reset;
//     reg start;
//     reg [STRIDE_WIDTH-1:0] stride;
//     reg [FILTER_SIZE_WIDTH-1:0] filter_size;
//     wire stall_signal;

//     reg [IFMAP_BUFFER_WIDTH-1:0] IFmap_buffer_in;
//     reg IFmap_buffer_write_enable;

//     reg [FILTER_BUFFER_WIDTH-1:0] filter_buffer_in;
//     reg filter_buffer_write_enable;
//     reg psum_mode;
//     reg interleaved_mode;

//     wire IFmap_buffer_full;
//     wire IFmap_buffer_ready;
//     wire filter_buffer_full;
//     wire filter_buffer_ready;

//     wire [RESULT_BUFFER_WIDTH-1:0] result_buffer_out;
//     wire result_buffer_empty;
//     wire result_buffer_valid;
//     reg result_buffer_read_enable;

//     reg [PSUM_BUFFER_WIDTH-1:0] psum_buffer_in;
//     wire psum_buffer_ready;
//     reg psum_buffer_wen;

//     // Instantiate CNN module
//     CNN #(
//         .IFMAP_BUFFER_WIDTH(IFMAP_BUFFER_WIDTH),
//         .IF_ADDR_WIDTH(IF_ADDR_WIDTH),
//         .IF_BUFFER_COLUMNS(IF_BUFFER_COLUMNS),
//         .IF_BUFFER_PAR_WRITE(IF_BUFFER_PAR_WRITE),
//         .IF_PAD_LENGTH(IF_PAD_LENGTH),
//         .FILTER_BUFFER_WIDTH(FILTER_BUFFER_WIDTH),
//         .FILTER_SIZE_WIDTH(FILTER_SIZE_WIDTH),
//         .FILTER_ADDR_WIDTH(FILTER_ADDR_WIDTH),
//         .FILTER_PAD_LENGTH(FILTER_PAD_LENGTH),
//         .FILTER_BUFFER_COLUMNS(FILTER_BUFFER_COLUMNS),
//         .FILTER_BUFFER_PAR_WRITE(FILTER_BUFFER_PAR_WRITE),
//         .RESULT_BUFFER_WIDTH(RESULT_BUFFER_WIDTH),
//         .RESULT_BUFFER_PAR_READ(RESULT_BUFFER_PAR_READ),
//         .RESULT_BUFFER_COLUMNS(RESULT_BUFFER_COLUMNS),
//         .ADD_OUT_WIDTH(ADD_OUT_WIDTH),
//         .STRIDE_WIDTH(STRIDE_WIDTH),
//         .MULT_WIDTH(MULT_WIDTH),
//         .I_WIDTH(I_WIDTH),
//         .PSUM_ADDR_WIDTH(PSUM_ADDR_WIDTH),
//         .PSUM_PAD_LENGTH(PSUM_PAD_LENGTH),
//         .PSUM_SPAD_WIDTH(PSUM_SPAD_WIDTH),
//         .PSUM_BUFFER_WIDTH(PSUM_BUFFER_WIDTH),
//         .PSUM_BUFFER_COLUMNS(PSUM_BUFFER_COLUMNS)
//     ) cnn (
//     .clk(clk),
//     .reset(reset),
//     .start(start),
//     .stride(stride),
//     .filter_size(filter_size),
//     .stall_signal(stall_signal),
//     .psum_mode(psum_mode),
//     .interleaved_mode(interleaved_mode),

//     .IFmap_buffer_in(IFmap_buffer_in),
//     .IFmap_buffer_full(IFmap_buffer_full),
//     .IFmap_buffer_ready(IFmap_buffer_ready),
//     .IFmap_buffer_write_enable(IFmap_buffer_write_enable),

//     .filter_buffer_in(filter_buffer_in),
//     .filter_buffer_full(filter_buffer_full),
//     .filter_buffer_ready(filter_buffer_ready),
//     .filter_buffer_write_enable(filter_buffer_write_enable),

//     .result_buffer_out(result_buffer_out),
//     .result_buffer_empty(result_buffer_empty),
//     .result_buffer_valid(result_buffer_valid),
//     .result_buffer_read_enable(result_buffer_read_enable),

//     .psum_buffer_in(psum_buffer_in),
//     .psum_buffer_wen(psum_buffer_wen),
//     .psum_buffer_ready(psum_buffer_ready)
//     );

//     // Clock generation
//     initial begin
//         clk = 0;
//         forever #(`CLK_HALF) clk = ~clk;
//     end

//     parameter input_if_count = 16;
//     parameter input_filter_count = 16;
//     parameter input_psum_count = 16;

//     reg [IFMAP_BUFFER_WIDTH-1:0] ifmaps [0:input_if_count-1];
//     reg [FILTER_BUFFER_WIDTH-1:0] filters [0:input_filter_count-1];
//     reg [PSUM_BUFFER_WIDTH-1: 0] psums [0:input_psum_count-1];
//     integer write = 1, skip = 0;

//     integer ifmap_write_index;
//     integer ifmap_write_or_skip [17:0]; //of size excel file rows excluding first row 
//     integer filter_write_index;
//     integer filter_write_or_skip [17:0];
//     integer psums_write_index;

//     initial begin
//         $readmemb("./file/test_11_filter.txt", filters);
//         $readmemb("./file/test_11_ifmap.txt", ifmaps);
//         $readmemb("./file/test_11_psum_input.txt", psums);
//         ifmap_write_index = 0;
//         filter_write_index = 0;
//         psums_write_index = 0;

//         ifmap_write_or_skip[0] = write;
//         ifmap_write_or_skip[1] = write;
//         ifmap_write_or_skip[2] = skip;
//         ifmap_write_or_skip[3] = write;
//         ifmap_write_or_skip[4] = write;
//         ifmap_write_or_skip[5] = write;
//         ifmap_write_or_skip[6] = write;
//         ifmap_write_or_skip[7] = write;
//         ifmap_write_or_skip[8] = write;
//         ifmap_write_or_skip[9] = write;
//         ifmap_write_or_skip[10] = skip;
//         ifmap_write_or_skip[11] = write;
//         ifmap_write_or_skip[12] = write;
//         ifmap_write_or_skip[13] = write;
//         ifmap_write_or_skip[14] = write;
//         ifmap_write_or_skip[15] = write;
//         ifmap_write_or_skip[16] = write;
//         ifmap_write_or_skip[17] = write;


//         filter_write_or_skip[0] = write;
//         filter_write_or_skip[1] = write;
//         filter_write_or_skip[2] = write;
//         filter_write_or_skip[3] = write;
//         filter_write_or_skip[4] = write;
//         filter_write_or_skip[5] = skip;
//         filter_write_or_skip[6] = write;
//         filter_write_or_skip[7] = write;
//         filter_write_or_skip[8] = skip;
//         filter_write_or_skip[9] = write;
//         filter_write_or_skip[10] = write;
//         filter_write_or_skip[11] = write;
//         filter_write_or_skip[12] = write;
//         filter_write_or_skip[13] = write;
//         filter_write_or_skip[14] = write;
//         filter_write_or_skip[15] = write;
//         filter_write_or_skip[16] = write;
//         filter_write_or_skip[17] = write;
//     end

//     integer k;
//     initial begin
//         #200;
//         for (k = 0; k < 16; k = k+1) begin
//             psum_buffer_wen = 1;
//             psum_buffer_in = psums[psums_write_index];
//             while (psum_buffer_ready == 0) begin
//                 #(`CLK_HALF);
//             end
//             #(`CLK + `CLK_HALF);
//             psum_buffer_wen = 0;
//             psums_write_index = psums_write_index + 1;
//             #(`CLK);
//         end
//         psum_buffer_wen = 0;
//     end

//     integer i;
//     initial begin
//         #200;
//         for (i = 0; i < 18; i = i+1) begin
//             if (ifmap_write_or_skip[i] == write) begin
//                 IFmap_buffer_write_enable = 1;
//                 IFmap_buffer_in = ifmaps[ifmap_write_index];
//                 while (IFmap_buffer_ready == 0) begin
//                     #(`CLK_HALF);
//                 end
//                 //$display("write ifmap index %d, value %b", ifmap_write_index, ifmaps[ifmap_write_index]);
//                 #(`CLK + `CLK_HALF);
//                 IFmap_buffer_write_enable = 0;
//                 ifmap_write_index = ifmap_write_index + 1;
//                 #(`CLK);
//             end else begin
//                 //$display("===== skip %d", i);
//                 #(`CLK * 50);
//             end
//         end

//         for (i = 0; i<4;i = i + 1) begin //insert an if of size filter_size to output the last psum
//             IFmap_buffer_write_enable = 1;
//             IFmap_buffer_in = i == 0 ? 18'b10_0000_0000_0000_0000 : i == 3 ? 18'b01_0000_0000_0000_0000 :  0;
//             while (IFmap_buffer_ready == 0) begin
//                 #(`CLK_HALF);
//             end
//         end
         
//     end

//     integer j;

//     initial begin
//         #200;
//         for (j = 0; j < 18; j = j+1) begin
//             if (filter_write_or_skip[j] == write) begin
//                 filter_buffer_write_enable = 1;
//                 filter_buffer_in = filters[filter_write_index];
//                 while (filter_buffer_ready == 0) begin
//                     #(`CLK_HALF);
//                 end
//                 //$display("write filter index %d, value %b", filter_write_index, filters[filter_write_index]);
//                 #(`CLK + `CLK_HALF);
//                 filter_buffer_write_enable = 0;
//                 filter_write_index = filter_write_index +1;
//                 #(`CLK);

//             end else begin
//                 //$display("===== skip %d", j);
//                 #(`CLK * 50);
//             end
//         end
//     end

//     integer read_psum_index;

//     initial begin
//         psum_mode = 1'b0;
//         interleaved_mode = 1'b0;
//         psum_buffer_in = 0;
//         psum_buffer_wen = 1'b0;
//         read_psum_index = 0;
//         reset = 1;
//         start = 0;
//         stride = 4;
//         filter_size = 4;
//         IFmap_buffer_write_enable = 0;
//         filter_buffer_write_enable = 0;
//         result_buffer_read_enable = 0;

//         // Reset sequence
//         #100;
//         reset = 0;
//         #30;

//         start = 1;
//         #10;
//         start = 0;
//         #10;

//         // Wait for processing
//         #4000;
        
        
//         psum_mode = 1'b1;
//         #(200 *`CLK);
//         for(read_psum_index = 0; read_psum_index < 16; read_psum_index = read_psum_index + 1) begin
//             result_buffer_read_enable = 1;
//             #(5 * `CLK);
//             result_buffer_read_enable = 0;
//             #(2 * `CLK);
//         end
//         $stop;
//     end

//     // Optional: Monitor outputs
//     /*initial begin
//         $monitor("Time=%0t result_out=%b", 
//                  $time, result_buffer_out);
//     end*/

//     always @(result_buffer_out) begin
//     $display("Time=%0t result_out=%b", 
//              $time, result_buffer_out);
//     end


// endmodule

`define CLK 10
`define CLK_HALF 5
module tb();

    // Parameters from the image
    parameter IFMAP_BUFFER_WIDTH = 18;    // ifmap_width
    parameter FILTER_BUFFER_WIDTH = 16;   // filter_width
    parameter FILTER_SIZE_WIDTH = 5;      // Same as filter_width for storage
    parameter STRIDE_WIDTH = 5;
    parameter IF_BUFFER_COLUMNS = 12;
    parameter FILTER_BUFFER_COLUMNS = 16;

    // Calculated parameters
    parameter IF_ADDR_WIDTH = $clog2(IFMAP_BUFFER_WIDTH - 2);          // $clog2(IFMAP_BUFFER_WIDTH - 2)
    parameter FILTER_ADDR_WIDTH = $clog2(FILTER_BUFFER_WIDTH);         // $clog2(FILTER_BUFFER_WIDTH)
    
    // Other parameters matching top module
    parameter IF_BUFFER_PAR_WRITE = 1;
    parameter IF_PAD_LENGTH = 12;
    parameter FILTER_PAD_LENGTH = 16;
    parameter FILTER_BUFFER_PAR_WRITE = 1;

    parameter RESULT_BUFFER_WIDTH = FILTER_BUFFER_WIDTH;
    parameter RESULT_BUFFER_PAR_READ = 1;
    parameter RESULT_BUFFER_COLUMNS = 64;
    
    parameter ADD_OUT_WIDTH = RESULT_BUFFER_WIDTH;
    parameter MULT_WIDTH = IFMAP_BUFFER_WIDTH - 2 + FILTER_BUFFER_WIDTH;
    parameter I_WIDTH = 5;

    parameter PSUM_SPAD_WIDTH = 16;
    parameter PSUM_PAD_LENGTH = 17; //from test cases
    parameter PSUM_ADDR_WIDTH = $clog2(PSUM_PAD_LENGTH);

    parameter PSUM_BUFFER_WIDTH = RESULT_BUFFER_WIDTH;
    parameter PSUM_BUFFER_COLUMNS = 16;

    // Testbench signals
    reg clk;
    reg reset;
    reg start;
    reg [STRIDE_WIDTH-1:0] stride;
    reg [FILTER_SIZE_WIDTH-1:0] filter_size;
    wire stall_signal;

    reg [IFMAP_BUFFER_WIDTH-1:0] IFmap_buffer_in;
    reg IFmap_buffer_write_enable;

    reg [FILTER_BUFFER_WIDTH-1:0] filter_buffer_in;
    reg filter_buffer_write_enable;
    reg psum_mode;
    reg interleaved_mode;

    wire IFmap_buffer_full;
    wire IFmap_buffer_ready;
    wire filter_buffer_full;
    wire filter_buffer_ready;

    wire [RESULT_BUFFER_WIDTH-1:0] result_buffer_out;
    wire result_buffer_empty;
    wire result_buffer_valid;
    reg result_buffer_read_enable;

    reg [PSUM_BUFFER_WIDTH-1:0] psum_buffer_in;
    wire psum_buffer_ready;
    reg psum_buffer_wen;

    // Instantiate CNN module
    CNN #(
        .IFMAP_BUFFER_WIDTH(IFMAP_BUFFER_WIDTH),
        .IF_ADDR_WIDTH(IF_ADDR_WIDTH),
        .IF_BUFFER_COLUMNS(IF_BUFFER_COLUMNS),
        .IF_BUFFER_PAR_WRITE(IF_BUFFER_PAR_WRITE),
        .IF_PAD_LENGTH(IF_PAD_LENGTH),
        .FILTER_BUFFER_WIDTH(FILTER_BUFFER_WIDTH),
        .FILTER_SIZE_WIDTH(FILTER_SIZE_WIDTH),
        .FILTER_ADDR_WIDTH(FILTER_ADDR_WIDTH),
        .FILTER_PAD_LENGTH(FILTER_PAD_LENGTH),
        .FILTER_BUFFER_COLUMNS(FILTER_BUFFER_COLUMNS),
        .FILTER_BUFFER_PAR_WRITE(FILTER_BUFFER_PAR_WRITE),
        .RESULT_BUFFER_WIDTH(RESULT_BUFFER_WIDTH),
        .RESULT_BUFFER_PAR_READ(RESULT_BUFFER_PAR_READ),
        .RESULT_BUFFER_COLUMNS(RESULT_BUFFER_COLUMNS),
        .ADD_OUT_WIDTH(ADD_OUT_WIDTH),
        .STRIDE_WIDTH(STRIDE_WIDTH),
        .MULT_WIDTH(MULT_WIDTH),
        .I_WIDTH(I_WIDTH),
        .PSUM_ADDR_WIDTH(PSUM_ADDR_WIDTH),
        .PSUM_PAD_LENGTH(PSUM_PAD_LENGTH),
        .PSUM_SPAD_WIDTH(PSUM_SPAD_WIDTH),
        .PSUM_BUFFER_WIDTH(PSUM_BUFFER_WIDTH),
        .PSUM_BUFFER_COLUMNS(PSUM_BUFFER_COLUMNS)
    ) cnn (
    .clk(clk),
    .reset(reset),
    .start(start),
    .stride(stride),
    .filter_size(filter_size),
    .stall_signal(stall_signal),
    .psum_mode(psum_mode),
    .interleaved_mode(interleaved_mode),

    .IFmap_buffer_in(IFmap_buffer_in),
    .IFmap_buffer_full(IFmap_buffer_full),
    .IFmap_buffer_ready(IFmap_buffer_ready),
    .IFmap_buffer_write_enable(IFmap_buffer_write_enable),

    .filter_buffer_in(filter_buffer_in),
    .filter_buffer_full(filter_buffer_full),
    .filter_buffer_ready(filter_buffer_ready),
    .filter_buffer_write_enable(filter_buffer_write_enable),

    .result_buffer_out(result_buffer_out),
    .result_buffer_empty(result_buffer_empty),
    .result_buffer_valid(result_buffer_valid),
    .result_buffer_read_enable(result_buffer_read_enable),

    .psum_buffer_in(psum_buffer_in),
    .psum_buffer_wen(psum_buffer_wen),
    .psum_buffer_ready(psum_buffer_ready)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(`CLK_HALF) clk = ~clk;
    end

    parameter input_if_count = 10;
    parameter input_filter_count = 10;
    parameter input_psum_count = 12;

    reg [IFMAP_BUFFER_WIDTH-1:0] ifmaps [0:input_if_count-1];
    reg [FILTER_BUFFER_WIDTH-1:0] filters [0:input_filter_count-1];
    reg [PSUM_BUFFER_WIDTH-1: 0] psums [0:input_psum_count-1];

    integer ifmap_write_index;
    integer filter_write_index;
    integer psums_write_index;

    initial begin
        $readmemb("./file/test_21_filter.txt", filters);
        $readmemb("./file/test_21_ifmap.txt", ifmaps);
        $readmemb("./file/test_21_psum_input.txt", psums);
        ifmap_write_index = 0;
        filter_write_index = 0;
        psums_write_index = 0;
    end

    integer k;
    initial begin
        #200;
        for (k = 0; k < 12; k = k+1) begin
            psum_buffer_wen = 1;
            psum_buffer_in = psums[psums_write_index];
            while (psum_buffer_ready == 0) begin
                #(`CLK_HALF);
            end
            #(`CLK + `CLK_HALF);
            psum_buffer_wen = 0;
            psums_write_index = psums_write_index + 1;
            #(`CLK);
        end
        psum_buffer_wen = 0;
    end

    integer i;
    initial begin
        #200;
        for (i = 0; i < 10; i = i+1) begin
            IFmap_buffer_write_enable = 1;
            IFmap_buffer_in = ifmaps[ifmap_write_index];
            while (IFmap_buffer_ready == 0) begin
                #(`CLK_HALF);
            end
            //$display("write ifmap index %d, value %b", ifmap_write_index, ifmaps[ifmap_write_index]);
            #(`CLK + `CLK_HALF);
            IFmap_buffer_write_enable = 0;
            ifmap_write_index = ifmap_write_index + 1;
            #(`CLK);
        end

        for (i = 0; i<4;i = i + 1) begin //insert an if of size filter_size to output the last psum
            IFmap_buffer_write_enable = 1;
            IFmap_buffer_in = i == 0 ? 18'b10_0000_0000_0000_0000 : i == 3 ? 18'b01_0000_0000_0000_0000 :  0;
            while (IFmap_buffer_ready == 0) begin
                #(`CLK_HALF);
            end
        end
         
    end

    integer j;

    initial begin
        #200;
        for (j = 0; j < 10; j = j+1) begin
            filter_buffer_write_enable = 1;
            filter_buffer_in = filters[filter_write_index];
            while (filter_buffer_ready == 0) begin
                #(`CLK_HALF);
            end
            //$display("write filter index %d, value %b", filter_write_index, filters[filter_write_index]);
            #(`CLK + `CLK_HALF);
            filter_buffer_write_enable = 0;
            filter_write_index = filter_write_index +1;
            #(`CLK);
        end
    end

    integer read_psum_index;

    initial begin
        psum_mode = 1'b0;
        interleaved_mode = 1'b1;
        psum_buffer_in = 0;
        psum_buffer_wen = 1'b0;
        read_psum_index = 0;
        reset = 1;
        start = 0;
        stride = 4;
        filter_size = 4;
        IFmap_buffer_write_enable = 0;
        filter_buffer_write_enable = 0;
        result_buffer_read_enable = 0;

        // Reset sequence
        #100;
        reset = 0;
        #30;

        start = 1;
        #10;
        start = 0;
        #10;

        // Wait for processing
        #4000;
        
        
        psum_mode = 1'b1;
        #(200 *`CLK);
        for(read_psum_index = 0; read_psum_index < 16; read_psum_index = read_psum_index + 1) begin
            result_buffer_read_enable = 1;
            #(5 * `CLK);
            result_buffer_read_enable = 0;
            #(2 * `CLK);
        end
        $stop;
    end

    // Optional: Monitor outputs
    /*initial begin
        $monitor("Time=%0t result_out=%b", 
                 $time, result_buffer_out);
    end*/

    always @(result_buffer_out) begin
    $display("Time=%0t result_out=%b", 
             $time, result_buffer_out);
    end


endmodule