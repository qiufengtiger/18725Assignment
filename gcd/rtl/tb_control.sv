module tb_control
    (input  logic           clk,
    input   logic           rst_b,
    input   logic   [15:0]  cnt,
    output  logic           cnt_en,
    output  logic           cnt_rst,
    input   logic           ops_rdy,
    output  logic           ops_val_nxt,
    output  logic           res_rdy_nxt,
    input   logic           res_val);

    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;

    logic   [1:0]   state, state_nxt;

    register #(.WL(2)) inst_reg_state (.clk(clk), .rst_b(rst_b), .d(state_nxt), .q(state), .wen(1'b1));

    // Next state logic
    always_comb begin
        case (state)
            S0: begin
                if (cnt < 5) state_nxt = S0;
                else state_nxt = S1;
            end
            S1: begin
                if (ops_rdy) state_nxt = S2;
                else state_nxt = S1;
            end
            S2: begin
                if (res_val) state_nxt = S1;
                else state_nxt = S2;
            end
            default: state_nxt = 'bX;
        endcase
    end

    // Output logic
    always_comb begin
        case (state)
            S0: begin
                if (cnt < 5) begin
                    ops_val_nxt = 0;
                    res_rdy_nxt = 0;
                    cnt_en = 1;
                    cnt_rst = 0;
                end else begin
                    ops_val_nxt = 0;
                    res_rdy_nxt = 0;
                    cnt_en = 1;
                    cnt_rst = 1;
                end
            end
            S1: begin
                if (ops_rdy) begin
                    ops_val_nxt = 1;
                    res_rdy_nxt = 0;
                    cnt_en = 0;
                    cnt_rst = 0;
                end else begin
                    ops_val_nxt = 1;
                    res_rdy_nxt = 0;
                    cnt_en = 0;
                    cnt_rst = 0;
                end
            end
            S2: begin
                if (res_val) begin
                    ops_val_nxt = 0;
                    res_rdy_nxt = 1;
                    cnt_en = 1;
                    if (cnt < 1023) cnt_rst = 0;
                    else cnt_rst = 1;
                end else begin
                    ops_val_nxt = 0;
                    res_rdy_nxt = 1;
                    cnt_en = 0;
                    cnt_rst = 0;
                end
            end
            default: begin
                ops_val_nxt = 'bX;
                res_rdy_nxt = 'bX;
                cnt_en = 'bX;
                cnt_rst = 'bX;
            end
        endcase
    end
endmodule: tb_control
