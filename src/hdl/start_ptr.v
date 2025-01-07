module start_ptr #(parameter ADDR_WIDTH = 16, parameter IF_LENGTH = 12)(
    input clk,
    input rst, //rst for complete rst
    input rst_p_valid, //rst for sp_valid
    input en_p_traverse,
    input [1:0] start_ptr_status,
    input next_start,
    input [ADDR_WIDTH-1:0] end_ptr,

    output reg sp_valid,
    output reg[ADDR_WIDTH-1:0] start_ptr // after finish, starts back from 0
);
    parameter IF_START = 2'b01;
    parameter EMPTY = 2'b00;

    always @(*) begin
        if (rst || rst_p_valid) begin
            sp_valid <= 0;
        end else begin
            sp_valid <= sp_valid ? 1 : start_ptr_status == IF_START ? 1 : 0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            //sp_valid <= 0;
            start_ptr <= 0;
        end else begin
            /*if (rst_p_valid) begin
                sp_valid <= 0;
            end else begin
                sp_valid <= sp_valid ? 1 : start_ptr_status == IF_START ? 1 : 0;
            end*/
            /*if (en_p_traverse) begin //TODO: en_p_traverse may be not needed, next_start does the job?
                start_ptr <= (start_ptr + 1) >= ({ADDR_WIDTH{1'b0}} + IF_LENGTH) ? 0 : start_ptr + 1;
            end*/
            if(next_start) begin
                start_ptr <= (end_ptr + 1'b1) >= ({ADDR_WIDTH{1'b0}} + IF_LENGTH) ? 0 : end_ptr + 1'b1;
            end
        end
    end

endmodule