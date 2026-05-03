`timescale 1ns/1ps

module sc_f_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] alpha,
    input  wire signed [W-1:0] beta,
    output wire signed [W:0]   f_out
);

    wire [W-1:0] min_abs;
    wire sign_alpha;
    wire sign_beta;
    wire sign_out;

    wire signed [W:0] mag_ext;

    assign sign_alpha = alpha[W-1];
    assign sign_beta  = beta[W-1];
    assign sign_out   = sign_alpha ^ sign_beta;

    abs_min_unit #(
        .W(W)
    ) u_abs_min_unit (
        .alpha(alpha),
        .beta(beta),
        .min_abs(min_abs)
    );

    assign mag_ext = {1'b0, min_abs};

    assign f_out = sign_out ? -mag_ext : mag_ext;

endmodule