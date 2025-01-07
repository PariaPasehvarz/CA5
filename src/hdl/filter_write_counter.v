module filter_write_counter #(
    parameter WIDTH = 10,  // to be determined in config file, should be clog length of scratchpad
    parameter MAX = 10'd24 // to be determined in config file, should be same as length of scratchpad
)(
    input wire clk,           
    input wire rst,         
    input wire count_en,    
    output reg [WIDTH-1:0] count, 
    output reg carry_out     
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            {carry_out, count} <= 0;
        end
        else if (count_en) begin
            if (count == MAX) begin
                count <= ({WIDTH{1'b0}} + MAX);
                carry_out <= 1'b1;
            end else begin
                {carry_out, count} <= count + 1'b1;
            end
        end
    end


endmodule