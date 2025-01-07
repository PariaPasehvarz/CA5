 module circular_buffer_controller (
    input wire clk,
    input wire rst,
    input wire full,
    input wire empty,
    input wire read_enable,
    input wire write_enable,
    output reg updateRP,
    output reg updateWP,
    output reg valid,
    output reg ready,
    output reg wen
);

    localparam [2:0] WAITING_FOR_SIGNAL = 3'b000,
                     START_READ = 3'b001,
                     UPDATE_READ_PTR = 3'b010,
                     STARTING_WRITE = 3'b011,
                     WRITE_IN_BUFFER = 3'b100,
                     UPDATE_WRITE_PTR = 3'b101;

    reg [2:0] present_state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst)
            present_state <= WAITING_FOR_SIGNAL;
        else
            present_state <= next_state;
    end

    always @(*) begin

        case (present_state)
            WAITING_FOR_SIGNAL: begin
                if (write_enable && !full)
                    next_state = STARTING_WRITE;
                else if (read_enable && !empty)
                    next_state = START_READ;
                else
                    next_state = WAITING_FOR_SIGNAL;
            end
            
            START_READ: begin
                if (read_enable)
                    next_state = START_READ;
                else
                    next_state = UPDATE_READ_PTR;
            end
            
            UPDATE_READ_PTR:
                next_state = WAITING_FOR_SIGNAL;
                
            STARTING_WRITE:
                next_state = WRITE_IN_BUFFER;
                
            WRITE_IN_BUFFER:
                next_state = UPDATE_WRITE_PTR;
                
            UPDATE_WRITE_PTR:
                next_state = WAITING_FOR_SIGNAL;
                
            default:
                next_state = WAITING_FOR_SIGNAL;
        endcase
    end

    always @(*) begin
        updateRP = 1'b0;
        updateWP = 1'b0;
        valid = 1'b0;
        ready = 1'b0;
        wen = 1'b0;

        case (present_state)            
            START_READ: begin
                valid = 1'b1;
            end
            
            UPDATE_READ_PTR: begin
                updateRP = 1'b1;
            end
            
            STARTING_WRITE: begin
                ready = 1'b1;
            end
            
            WRITE_IN_BUFFER: begin
                wen = 1'b1;
            end
            
            UPDATE_WRITE_PTR: begin
                updateWP = 1'b1;
            end
        endcase
        // $display("updateRP: %b, updateWP: %b, valid: %b, ready: %b, wen: %b", updateRP, updateWP, valid, ready, wen);
    end

endmodule