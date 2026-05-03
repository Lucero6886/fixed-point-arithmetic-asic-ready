`timescale 1ns/1ps

module sc_decoder_n8 #(
    parameter W = 6
)(
    input  wire signed [W-1:0] llr0,
    input  wire signed [W-1:0] llr1,
    input  wire signed [W-1:0] llr2,
    input  wire signed [W-1:0] llr3,
    input  wire signed [W-1:0] llr4,
    input  wire signed [W-1:0] llr5,
    input  wire signed [W-1:0] llr6,
    input  wire signed [W-1:0] llr7,

    input  wire        [7:0]   frozen_mask,
    output wire        [7:0]   u_hat
);

    localparam W1 = W + 1;

    // ------------------------------------------------------------
    // Left branch LLRs: f(Li, L(i+4))
    // Width grows from W bits to W+1 bits.
    // ------------------------------------------------------------
    wire signed [W:0] left0;
    wire signed [W:0] left1;
    wire signed [W:0] left2;
    wire signed [W:0] left3;

    sc_f_unit #(.W(W)) u_f_left0 (
        .alpha(llr0),
        .beta (llr4),
        .f_out(left0)
    );

    sc_f_unit #(.W(W)) u_f_left1 (
        .alpha(llr1),
        .beta (llr5),
        .f_out(left1)
    );

    sc_f_unit #(.W(W)) u_f_left2 (
        .alpha(llr2),
        .beta (llr6),
        .f_out(left2)
    );

    sc_f_unit #(.W(W)) u_f_left3 (
        .alpha(llr3),
        .beta (llr7),
        .f_out(left3)
    );

    // ------------------------------------------------------------
    // Decode left N=4 branch: u0, u1, u2, u3
    // Since left LLRs are W+1 bits, instantiate sc_decoder_n4
    // with W1 = W + 1.
    // ------------------------------------------------------------
    wire [3:0] u_left;

    sc_decoder_n4 #(.W(W1)) u_sc_decoder_left (
        .llr0(left0),
        .llr1(left1),
        .llr2(left2),
        .llr3(left3),
        .frozen_mask(frozen_mask[3:0]),
        .u_hat(u_left)
    );

    // ------------------------------------------------------------
    // Partial sums for right branch.
    // partial = polar_encode_n4(u_left)
    //
    // For N=4 Polar transform:
    // x0 = u0 ^ u1 ^ u2 ^ u3
    // x1 = u1 ^ u3
    // x2 = u2 ^ u3
    // x3 = u3
    // ------------------------------------------------------------
    wire [3:0] partial;

    assign partial[0] = u_left[0] ^ u_left[1] ^ u_left[2] ^ u_left[3];
    assign partial[1] = u_left[1] ^ u_left[3];
    assign partial[2] = u_left[2] ^ u_left[3];
    assign partial[3] = u_left[3];

    // ------------------------------------------------------------
    // Right branch LLRs: g(Li, L(i+4), partial[i])
    // Width grows from W bits to W+1 bits.
    // ------------------------------------------------------------
    wire signed [W:0] right0;
    wire signed [W:0] right1;
    wire signed [W:0] right2;
    wire signed [W:0] right3;

    sc_g_unit #(.W(W)) u_g_right0 (
        .alpha(llr0),
        .beta (llr4),
        .u_hat(partial[0]),
        .g_out(right0)
    );

    sc_g_unit #(.W(W)) u_g_right1 (
        .alpha(llr1),
        .beta (llr5),
        .u_hat(partial[1]),
        .g_out(right1)
    );

    sc_g_unit #(.W(W)) u_g_right2 (
        .alpha(llr2),
        .beta (llr6),
        .u_hat(partial[2]),
        .g_out(right2)
    );

    sc_g_unit #(.W(W)) u_g_right3 (
        .alpha(llr3),
        .beta (llr7),
        .u_hat(partial[3]),
        .g_out(right3)
    );

    // ------------------------------------------------------------
    // Decode right N=4 branch: u4, u5, u6, u7
    // ------------------------------------------------------------
    wire [3:0] u_right;

    sc_decoder_n4 #(.W(W1)) u_sc_decoder_right (
        .llr0(right0),
        .llr1(right1),
        .llr2(right2),
        .llr3(right3),
        .frozen_mask(frozen_mask[7:4]),
        .u_hat(u_right)
    );

    // ------------------------------------------------------------
    // Final output
    // u_hat[0] is decoded first, u_hat[7] is decoded last.
    // ------------------------------------------------------------
    assign u_hat = {u_right, u_left};

endmodule