`timescale 1ns/1ps

module abs_min_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] alpha,
    input  wire signed [W-1:0] beta,
    output wire        [W-1:0] min_abs
);

    wire [W-1:0] abs_alpha;
    wire [W-1:0] abs_beta;

    abs_unit #(
        .W(W)
    ) u_abs_alpha (
        .x(alpha),
        .y(abs_alpha)
    );

    abs_unit #(
        .W(W)
    ) u_abs_beta (
        .x(beta),
        .y(abs_beta)
    );

    min_comparator #(
        .W(W)
    ) u_min_comparator (
        .a(abs_alpha),
        .b(abs_beta),
        .y(min_abs)
    );

endmodule