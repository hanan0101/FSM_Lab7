module digital_lock_Task4(    input logic clk,
    input logic reset,    input logic [3:0] user_password,  
    input logic open_btn,                 input logic close_btn,            
    output logic [6:0] seven_seg_display,     output logic locked   // 1:closed , 0:open
);
    typedef enum logic [1:0] {        LOCKED,   //00
        UNLOCKED, //01        FAILED    //10
    } state_t;
    state_t current_state, next_state;
    logic [3:0] fixed_password = 4'b1010;     logic [1:0] wrong_attempts;           
    logic [31:0] failed_timer;                logic open_btn_debounced, close_btn_debounced;
    //Debouncing
    logic open_btn_prev, close_btn_prev;    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin            open_btn_prev <= 0;
            close_btn_prev <= 0;        end else begin
            open_btn_prev <= open_btn;            close_btn_prev <= close_btn;
        end    end
    assign open_btn_debounced = open_btn && !open_btn_prev;    assign close_btn_debounced = close_btn && !close_btn_prev;
     //(State Transition)
    always_ff @(posedge clk or posedge reset) begin        if (reset) begin
            current_state <= LOCKED;            wrong_attempts <= 0;
            failed_timer <= 0;        end else begin
            current_state <= next_state;
            //couner for false attempts            if (current_state == LOCKED && open_btn_debounced && user_password != fixed_password)
                wrong_attempts <= wrong_attempts + 1; //it will counte wrong attempts             else if (current_state == FAILED && failed_timer == 32'd999999999) // بعد 10 ثوانٍ
                wrong_attempts <= 0; // when timer reaches 10 sec
            // when it is in FAILED state             if (current_state == FAILED)
                failed_timer <= failed_timer + 1; //increment            else
                failed_timer <= 0;        end
    end
    always_comb begin
        next_state = current_state;         case (current_state)
            LOCKED: begin                if (wrong_attempts >= 3)  // 3 false
                    next_state = FAILED;                else if (open_btn_debounced) begin //open
                    if (user_password == fixed_password)  //true password                        next_state = UNLOCKED;
                end            end

            UNLOCKED: begin                if (close_btn_debounced)  //Close
                    next_state = LOCKED;            end
            FAILED: begin
                if (failed_timer == 32'd999999999)  // when reaches 10 sec move to locked                    next_state = LOCKED;
            end        endcase
    end
    //7-seg    always_comb begin
        case (current_state)            LOCKED: begin
                seven_seg_display = 7'b1000111;  // 'C'                locked = 1;  //close
            end            UNLOCKED: begin
                seven_seg_display = 7'b0000110;  // 'o'                 locked = 0;  // open
            end            FAILED: begin
                seven_seg_display = 7'b0001110;  // 'F'                 locked = 1;  // close
            end        endcase
    end
endmodule
