module end_ptr #(parameter ADDR_WIDTH = 16)( // EndPtr is combinational, no clk
    input rst,
    input rst_p_valid,
    input update_end_ptr,
    input [ADDR_WIDTH-1:0] end_ptr_in, //connect to IF_raddr

    output reg ep_valid,
    output reg [ADDR_WIDTH-1:0] end_ptr
);


    always @(*) begin
        if (rst) begin
            end_ptr <= 0;
            ep_valid <= 0;
        end else if (rst_p_valid) begin
            ep_valid <= 0;
        end else if (update_end_ptr) begin
            end_ptr <= end_ptr_in;
            ep_valid <= 1;
        end
    end


endmodule