// Feng Qiu
// 18725 Assignment 1
module datapath 
    #(parameter WL = 8)
    (input  logic               clk,
    input   logic               rst_b,
    input   logic   [WL-1:0]    op_a,
    input   logic   [WL-1:0]    op_b,
    output  logic   [WL-1:0]    res,
    input logic [1:0] mux_A_select,
    input logic mux_B_select,
    output logic A_B_lt_result,
    output logic B_0_ne_result,
    input logic reg_A_wen,
    input logic reg_B_wen);

    // algorithm:
    // while(true):
    //     if(A < B):
    //         swap A & B
    //     else if(B != 0):
    //         A = A - B
    //     else:
    //         return A

    logic [WL-1:0] mux_A_out, mux_B_out;
    logic [WL-1:0] reg_A_out, reg_B_out;
    logic [WL-1:0] subtract_out;

    // store A and B values
    register #(.WL(WL)) inst_reg_A (.clk(clk), .rst_b(rst_b), .d(mux_A_out), .q(reg_A_out), .wen(reg_A_wen));
    register #(.WL(WL)) inst_reg_B (.clk(clk), .rst_b(rst_b), .d(mux_B_out), .q(reg_B_out), .wen(reg_B_wen));

    // A inputs can from op_a, A-B or swapped B
    // select: 00->op_a, 01->A-B, 10->B
    mux4 #(.WL(WL)) inst_mux_A (.in3({(WL){1'b0}}), .in2(reg_B_out), .in1(subtract_out), .in0(op_a), .select(mux_A_select), .result(mux_A_out));

    // B inputs can from op_b or swapped A
    // select: 0->op_b, 1->B
    mux2 #(.WL(WL)) inst_mux_B (.in1(reg_A_out), .in0(op_b), .select(mux_B_select), .result(mux_B_out));

    lt2 #(.WL(WL)) inst_lt (.comparand1(reg_A_out), .comparand2(reg_B_out), .result(A_B_lt_result));

    ne2 #(.WL(WL)) inst_ne (.comparand1(reg_B_out), .comparand2({(WL){1'b0}}), .result(B_0_ne_result));

    subtract2 #(.WL(WL)) inst_sub (.minuend(reg_A_out), .subtrahend(reg_B_out), .difference(subtract_out));

    assign res = reg_A_out;

endmodule: datapath

module ne2
    #(parameter WL = 8)
    (input logic [WL-1:0] comparand1,
    input logic [WL-1:0] comparand2,
    output logic result);

    assign result = (comparand1 != comparand2);
endmodule: ne2

module lt2
    #(parameter WL = 8)
    (input logic [WL-1:0] comparand1,
    input logic [WL-1:0] comparand2,
    output logic  result);

    assign result = (comparand1 < comparand2);
endmodule: lt2

module subtract2
    #(parameter WL = 8)
    (input logic [WL-1:0] minuend,
    input logic [WL-1:0] subtrahend,
    output logic [WL-1:0] difference);

    assign difference = minuend - subtrahend;
endmodule: subtract2

module mux2
    #(parameter WL = 8)
    (input logic [WL-1:0] in1,
    input logic [WL-1:0] in0,
    input logic select,
    output logic [WL-1:0] result);

    assign result = (select) ? in1 : in0;
endmodule: mux2

module mux4
    #(parameter WL = 8)
    (input logic [WL-1:0] in3,
    input logic [WL-1:0] in2,
    input logic [WL-1:0] in1,
    input logic [WL-1:0] in0,
    input logic [1:0] select,
    output logic [WL-1:0] result);

    assign result = select[1] ? (select[0] ? in3 : in2) : (select[0] ? in1 : in0);
endmodule: mux4