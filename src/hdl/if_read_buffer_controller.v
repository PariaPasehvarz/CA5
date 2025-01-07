module if_read_buffer_controller (
    input wire clk,
    input wire rst,
    input wire IFMap_can_write,
    input wire buffer_valid,
    
    output reg buffer_read_enable,
    output reg pad_wen,
    output reg pad_counter_enable,
    output reg set_status
);

    localparam ASK_READ      = 2'd0;
    localparam WRITE_SCRATCH = 2'd1;
    localparam READ_DONE     = 2'd2;
    
    reg [1:0] current_state, next_state;
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= ASK_READ;
        else
            current_state <= next_state;
    end
    
    always @(*) begin
        next_state = current_state;  
        
        case (current_state)
            ASK_READ: begin
                next_state = buffer_valid ? WRITE_SCRATCH : ASK_READ;
            end
            WRITE_SCRATCH: begin
                next_state = READ_DONE;
            end
            READ_DONE: begin
                next_state = ASK_READ;
            end
            default: next_state = ASK_READ;
        endcase
    end
    
    always @(*) begin
        
        {buffer_read_enable,pad_wen,pad_counter_enable,set_status} = 0;

        
        case (current_state)
            ASK_READ: begin
                buffer_read_enable = (IFMap_can_write == 1'b1);
            end
            
            WRITE_SCRATCH: begin
                buffer_read_enable = 1;
                pad_wen = 1;
                pad_counter_enable = 1;
                set_status = 1;
            end
            READ_DONE: begin
                //nothing
            end
        endcase
    end

endmodule