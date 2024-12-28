module digital_lock (    input logic clk,
    input logic reset,    input logic [3:0] user_password,
    input logic open_btn,     input logic close_btn,           
    output logic [6:0] seven_seg_display,     output logic locked  // 1:closed , 0:open
);
    typedef enum logic [1:0] {        LOCKED,  //00 
        UNLOCKED  //01    } state_t;
    state_t current_state, next_state;
    logic [3:0] fixed_password = 4'b1010;
    always_ff @(posedge clk or posedge reset) begin
        if (reset)            current_state <= LOCKED;  
        else            current_state <= next_state;
    end
//FSM    always_comb begin
        case (current_state)            LOCKED: begin
                if (open_btn) begin                    if (user_password == fixed_password)  // check the password
                        next_state = UNLOCKED;                    else
                        next_state = LOCKED;                end else
                    next_state = LOCKED;            end
            UNLOCKED: begin
                if (close_btn)  // if pressed in the closed                    next_state = LOCKED; //if pressed in the closed it will become closed
                else                    next_state = UNLOCKED; //if not pressed in the closed it will become open
            end
            default: next_state = LOCKED;         endcase
    end
//7-seg    always_comb begin
        case (current_state)            LOCKED: begin
                seven_seg_display = 7'b1000111;  // C                locked = 1;  //close
            end            UNLOCKED: begin
                seven_seg_display = 7'b0000110;  // O                locked = 0;  //open
            end        endcase
    end
endmodule
