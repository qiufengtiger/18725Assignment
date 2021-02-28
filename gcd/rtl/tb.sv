module tb();
    // Number of test inputs
    parameter N = 1024;

    logic           clk, rst_b;
    logic           ops_rdy, ops_val, res_rdy, res_val;
    logic           ops_rdy_next, ops_val_nxt, res_rdy_nxt, res_val_nxt;
    logic   [7:0]   op_a, op_b, res;
    logic   [7:0]   op_a_nxt, op_b_nxt, res_nxt;
    logic   [15:0]  input_mem [0:N-1];
    logic   [7:0]   output_mem [0:N-1];
    logic   [15:0]  cnt;
    logic           cnt_en, cnt_rst;

    assign op_a_nxt = input_mem[cnt][15:8];
    assign op_b_nxt = input_mem[cnt][7:0];

    register #(.WL(1)) inst_reg_ops_rdy (.clk(~clk), .rst_b(rst_b), .d(ops_rdy_nxt), .q(ops_rdy), .wen(1'b1));
    register #(.WL(1)) inst_reg_ops_val (.clk(~clk), .rst_b(rst_b), .d(ops_val_nxt), .q(ops_val), .wen(1'b1));
    register #(.WL(1)) inst_reg_res_rdy (.clk(~clk), .rst_b(rst_b), .d(res_rdy_nxt), .q(res_rdy), .wen(1'b1));
    register #(.WL(1)) inst_reg_res_val (.clk(~clk), .rst_b(rst_b), .d(res_val_nxt), .q(res_val), .wen(1'b1));
    register #(.WL(8)) inst_reg_op_a (.clk(~clk), .rst_b(rst_b), .d(op_a_nxt), .q(op_a), .wen(1'b1));
    register #(.WL(8)) inst_reg_op_b (.clk(~clk), .rst_b(rst_b), .d(op_b_nxt), .q(op_b), .wen(1'b1));
    register #(.WL(8)) inst_reg_res (.clk(~clk), .rst_b(rst_b), .d(res_nxt), .q(res), .wen(1'b1));

    counter #(.WL(16)) inst_counter (.clk(clk), .rst_b(rst_b), .cnt_en(cnt_en), .cnt_rst(cnt_rst), .cnt(cnt));
    
    chip inst_chip (.clk(clk), .rst_b(rst_b), .op_a(op_a), .op_b(op_b), .res(res_nxt), .ops_val(ops_val), .ops_rdy(ops_rdy_nxt), .res_rdy(res_rdy), .res_val(res_val_nxt));

    tb_control inst_tb_control (.clk(clk), .rst_b(rst_b), .cnt(cnt), .cnt_en(cnt_en), .cnt_rst(cnt_rst), .ops_rdy(ops_rdy), .ops_val_nxt(ops_val_nxt), .res_rdy_nxt(res_rdy_nxt), .res_val(res_val));

    initial begin
        clk = 0;
        forever begin
            #5;
            clk = ~clk;
        end
    end
    initial begin
        rst_b = 0;
        #10;
        rst_b = 1;
    end
    initial begin
        $readmemb("../data/input.txt", input_mem);
    end
    integer f, i;
    always @(posedge clk) begin
        if (res_rdy && res_val) begin
            output_mem[cnt] = res;
            if (cnt == N-1) begin
                $writememb("./output.txt", output_mem);
                $finish();
            end
        end
    end
    initial begin
        $dumpfile("chip.vcd");
        $dumpvars(4);
    end
    // initial begin
    //     #10000;
    //     $finish();
    // end
endmodule: tb
