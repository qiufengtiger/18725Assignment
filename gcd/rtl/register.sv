module register 
    #(parameter WL = 1)
    (input  logic               clk,
    input   logic               rst_b,
    input   logic   [WL-1:0]    d,
    output  logic   [WL-1:0]    q,
    input   logic               wen);

    always_ff @(posedge clk, negedge rst_b) begin
        if (~rst_b)
            q <= 'b0;
        else begin
            if (wen)
                q <= d;
        end
    end
endmodule: register
