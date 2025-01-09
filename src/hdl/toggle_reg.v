module toggle_reg(input rst, clk, toggle, output reg out);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        out <= 0;
    end else begin
        out <= toggle ? !out : out;
    end
end

endmodule