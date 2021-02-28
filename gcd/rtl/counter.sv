module counter 
    #(parameter WL = 16)
    (input  logic               clk,
    input   logic               rst_b,
    input   logic               cnt_en,
    input   logic               cnt_rst,
    output  logic   [WL-1:0]    cnt);

    logic   [WL-1:0]    cnt_nxt;
    always_comb begin
        if (cnt_rst) cnt_nxt = 0;
        else cnt_nxt = cnt + 1;
    end

    register #(.WL(WL)) inst_reg_cnt (.clk(clk), .rst_b(rst_b), .d(cnt_nxt), .q(cnt), .wen(cnt_en));
endmodule: counter
