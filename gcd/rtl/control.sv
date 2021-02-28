module control 
    #(parameter WL = 8)
    (input  logic   clk,
    input   logic   rst_b,
    input   logic   ops_val,
    output  logic   ops_rdy,
    input   logic   res_rdy,
    output  logic   res_val,
    input logic A_B_lt_result,
    input logic B_0_ne_result,
    output logic [1:0] mux_A_select,
    output logic mux_B_select,
    output logic reg_A_wen,
    output logic reg_B_wen);

    // FSM states:
    // READY:
    // ops_rdy = 1, res_val = 0
    // mux_A_select = 00, mux_B_select = 0, reg_A_wen = 1, reg_B_wen = 1
    // ->EXEC if ops_val = 1, ->READY otherwise
    //
    // EXEC:
    // ops_rdy = 0, res_val = 0
    // if A_B_lt_result: mux_A_select = 10, mux_B_select = 1, reg_A_wen = 1, reg_B_wen = 1 ->EXEC
    // elif B_0_ne_result: mux_A_select = 01, mux_B_select = x, reg_A_wen = 1, reg_B_wen = 0 -> EXEC
    // else: -> OUTPUT
    // 
    // OUTPUT:
    // ops_rdy = 0, res_vel = 1
    // mux_A_select = xx, mux_B_select = x, reg_A_wen = 0, reg_B_wen = 0
    // -> READY if res_rdy = 1, -> OUTPUT otherwise

    localparam READY = 2'b00;
    localparam EXEC = 2'b01;
    localparam OUTPUT = 2'b10;

    logic [1:0] state, next_state;
    register #(.WL(2)) inst_reg_control_state (.clk(clk), .rst_b(rst_b), .d(next_state), .q(state), .wen(1'b1));

    always_comb begin
        case(state)
            READY: begin
                if(~rst_b) next_state = READY;
                else if(ops_val) next_state = EXEC;
                else next_state = READY;
            end
            EXEC: begin
                if(~rst_b) next_state = READY;
                else if(A_B_lt_result|B_0_ne_result) next_state = EXEC;
                else next_state = OUTPUT;
            end
            OUTPUT: begin
                if(~rst_b) next_state = READY;
                else if(res_rdy) next_state = READY;
                else next_state = OUTPUT;
            end 
            default: begin
                next_state = READY;
            end
        endcase
    end

    always_comb begin
        case(state)
            READY: begin
                ops_rdy = 1;
                res_val = 0;
                mux_A_select = 00;
                mux_B_select = 0;
                reg_A_wen = 1;
                reg_B_wen = 1;
            end
            EXEC: begin
                ops_rdy = 0;
                res_val = 0;
                if(A_B_lt_result) begin
                    mux_A_select = 10;
                    mux_B_select = 1;
                    reg_A_wen = 1;
                    reg_B_wen = 1;
                end
                else if(B_0_ne_result) begin
                    mux_A_select = 01;
                    mux_B_select = 1'bx;
                    reg_A_wen = 1;
                    reg_B_wen = 0;
                end
                else begin
                    mux_A_select = 2'bxx;
                    mux_B_select = 1'bx;
                    reg_A_wen = 0;
                    reg_B_wen = 0;
                end
            end
            OUTPUT: begin
                ops_rdy = 0;
                res_val = 1;
                mux_A_select = 2'bxx;
                mux_B_select = 1'bx;
                reg_A_wen = 0;
                reg_B_wen = 0;
            end
            // default: begin
            //     ops_rdy = 1;
            //     res_val = 1;
            //     mux_A_select = 00;
            //     mux_B_select = 0;
            //     reg_A_wen = 1;
            //     reg_B_wen = 1;
            // end
        endcase
    end
endmodule: control
