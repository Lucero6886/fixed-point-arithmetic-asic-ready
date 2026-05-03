`timescale 1ns/1ps

module min_comparator_top #(
    parameter W = 6
)(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         en,
    input  wire [W-1:0] a,
    input  wire [W-1:0] b,
    output reg  [W-1:0] y
);

    wire [W-1:0] y_comb;

    min_comparator #(
        .W(W)
    ) u_min_comparator (
        .a(a),
        .b(b),
        .y(y_comb)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y <= {W{1'b0}};
        end else if (en) begin
            y <= y_comb;
        end else begin
            y <= y;
        end
    end

endmodule