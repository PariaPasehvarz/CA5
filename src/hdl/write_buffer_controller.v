module write_buffer_controller (
    input wire clk,
    input wire rst,
    input wire done,          // from main controller
    input wire buffer_ready,  
    
    output reg buffer_write_en,
    output reg [1:0] stall
);

    localparam IDLE        = 3'd0;
    localparam WRITE_CHECK = 3'd1;
    localparam WRITE_START = 3'd2;
    localparam WRITE_GRANTED = 3'd3;
    localparam WRITE_DONE  = 3'd4;
    localparam WRITE_FAIL  = 3'd5;
    
    reg [2:0] current_state, next_state;
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end
    
    always @(*) begin
        next_state = current_state; 
        
        case (current_state)
            IDLE: begin
                next_state = done ? WRITE_CHECK : IDLE;
            end
            
            WRITE_CHECK: begin
                next_state = WRITE_START;
            end
            
            WRITE_START: begin
                next_state = buffer_ready ? WRITE_GRANTED : WRITE_FAIL;
            end
            
            WRITE_GRANTED: begin
                next_state = WRITE_DONE;
            end
            
            WRITE_DONE: begin
                next_state = IDLE;
            end
            
            WRITE_FAIL: begin
                //next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    always @(*) begin
        {buffer_write_en, stall} = 0;
        
        case (current_state)
            WRITE_CHECK: begin
                buffer_write_en = 1'b1;
            end
            
            WRITE_DONE: begin
                stall = 2'b10; 
            end

            WRITE_FAIL: begin
                stall = 2'b11;
            end
        endcase
    end

endmodule