`timescale 1ns/1ps

module abs_min_unit_top #(
    parameter W = 6
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               en,
    input  wire signed [W-1:0] alpha,
    input  wire signed [W-1:0] beta,
    output reg         [W-1:0] min_abs
);

    wire [W-1:0] min_abs_comb;

    abs_min_unit #(
        .W(W)
    ) u_abs_min_unit (
        .alpha(alpha),
        .beta(beta),
        .min_abs(min_abs_comb)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            min_abs <= {W{1'b0}};
        end else if (en) begin
            min_abs <= min_abs_comb;
        end else begin
            min_abs <= min_abs;
        end
    end

endmodule