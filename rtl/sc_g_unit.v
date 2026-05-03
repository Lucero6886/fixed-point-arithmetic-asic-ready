`timescale 1ns/1ps

module sc_g_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] alpha,
    input  wire signed [W-1:0] beta,
    input  wire               u_hat,
    output wire signed [W:0]   g_out
);

    wire signed [W:0] add_result;
    wire signed [W:0] sub_result;

    // add_result = beta + alpha
    signed_adder #(
        .W(W)
    ) u_signed_adder (
        .a(beta),
        .b(alpha),
        .y(add_result)
    );

    // sub_result = beta - alpha
    signed_subtractor #(
        .W(W)
    ) u_signed_subtractor (
        .a(beta),
        .b(alpha),
        .y(sub_result)
    );

    assign g_out = (u_hat == 1'b0) ? add_result : sub_result;

endmodule