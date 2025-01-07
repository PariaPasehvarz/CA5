module IFMap_status #(parameter LENGTH = 16,parameter ADDR_WIDTH = 4)(
    input clk,
    input rst,
    input [ADDR_WIDTH-1:0] start_ptr, //TODO: what if length is not 2^n?
    input [ADDR_WIDTH-1:0] end_ptr,
    input make_empty,
    input set_status,
    input [1:0] next_status,
    input [ADDR_WIDTH-1:0] status_write_addr, // to IFMap write counter
    input [ADDR_WIDTH-1:0] read_addr, // to IFMap read address generator
    

    output IFMap_can_write,
    output reading_empty,
    output [1:0] start_ptr_status,
    output [1:0] read_addr_status,
    output IF_empty
);

    parameter EMPTY = 2'b00;
    parameter IF_START = 2'b01;
    parameter IF_END = 2'b10;
    parameter NONE = 2'b11;

    // make a momory of LENGTH each item 2 bits
    reg [1:0] status_memory [0:LENGTH-1];

    // read the status memory
    assign start_ptr_status = status_memory[start_ptr];
    assign read_addr_status = status_memory[read_addr];


    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < LENGTH; i = i + 1) begin
                status_memory[i] <= EMPTY;
            end
        end else begin
            if (make_empty) begin
                //make values in range start_ptr end_ptr empty
                for (i = start_ptr; i <= end_ptr; i = i + 1) begin
                    status_memory[i] <= EMPTY;
                end
            end
            else if (set_status) begin // make empty has priority
                status_memory[status_write_addr] <= next_status;
            end
        end
    end

    assign IFMap_can_write = (status_memory[status_write_addr] == EMPTY);

    assign reading_empty = (status_memory[read_addr] == EMPTY);
    
    reg IF_empty_reg;

    always @(*) begin
        IF_empty_reg = 1; // assume empty by default
        for (i = 0; i < LENGTH; i = i + 1) begin
            if (status_memory[i] != EMPTY) begin
                IF_empty_reg = 0; // not empty
            end
        end
    end

    assign IF_empty = IF_empty_reg;

endmodule