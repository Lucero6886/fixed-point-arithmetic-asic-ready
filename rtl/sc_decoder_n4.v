`timescale 1ns/1ps

module sc_decoder_n4 #(
    parameter W = 6
)(
    input  wire signed [W-1:0] llr0,
    input  wire signed [W-1:0] llr1,
    input  wire signed [W-1:0] llr2,
    input  wire signed [W-1:0] llr3,
    input  wire        [3:0]   frozen_mask,
    output wire        [3:0]   u_hat
);

    // First-level left branch LLRs
    wire signed [W:0] left0;
    wire signed [W:0] left1;

    // LLRs for u0 and u1
    wire signed [W+1:0] u0_llr;
    wire signed [W+1:0] u1_llr;

    // Partial sums from decoded left branch
    wire partial0;
    wire partial1;

    // Right branch LLRs
    wire signed [W:0] right0;
    wire signed [W:0] right1;

    // LLRs for u2 and u3
    wire signed [W+1:0] u2_llr;
    wire signed [W+1:0] u3_llr;

    wire u0_dec;
    wire u1_dec;
    wire u2_dec;
    wire u3_dec;

    // ------------------------------------------------------------
    // Step 1: compute left LLRs
    // left0 = f(llr0, llr2)
    // left1 = f(llr1, llr3)
    // ------------------------------------------------------------
    sc_f_unit #(
        .W(W)
    ) u_f_left0 (
        .alpha(llr0),
        .beta(llr2),
        .f_out(left0)
    );

    sc_f_unit #(
        .W(W)
    ) u_f_left1 (
        .alpha(llr1),
        .beta(llr3),
        .f_out(left1)
    );

    // ------------------------------------------------------------
    // Step 2: decode u0
    // u0_llr = f(left0, left1)
    // ------------------------------------------------------------
    sc_f_unit #(
        .W(W+1)
    ) u_f_u0 (
        .alpha(left0),
        .beta(left1),
        .f_out(u0_llr)
    );

    assign u0_dec   = u0_llr[W+1];  // sign bit: negative LLR -> bit 1
    assign u_hat[0] = frozen_mask[0] ? 1'b0 : u0_dec;

    // ------------------------------------------------------------
    // Step 3: decode u1
    // u1_llr = g(left0, left1, u0_hat)
    // ------------------------------------------------------------
    sc_g_unit #(
        .W(W+1)
    ) u_g_u1 (
        .alpha(left0),
        .beta(left1),
        .u_hat(u_hat[0]),
        .g_out(u1_llr)
    );

    assign u1_dec   = u1_llr[W+1];
    assign u_hat[1] = frozen_mask[1] ? 1'b0 : u1_dec;

    // ------------------------------------------------------------
    // Step 4: compute partial sums for right branch
    // For N=2 left branch:
    // partial0 = u0_hat XOR u1_hat
    // partial1 = u1_hat
    // ------------------------------------------------------------
    assign partial0 = u_hat[0] ^ u_hat[1];
    assign partial1 = u_hat[1];

    // ------------------------------------------------------------
    // Step 5: compute right LLRs
    // right0 = g(llr0, llr2, partial0)
    // right1 = g(llr1, llr3, partial1)
    // ------------------------------------------------------------
    sc_g_unit #(
        .W(W)
    ) u_g_right0 (
        .alpha(llr0),
        .beta(llr2),
        .u_hat(partial0),
        .g_out(right0)
    );

    sc_g_unit #(
        .W(W)
    ) u_g_right1 (
        .alpha(llr1),
        .beta(llr3),
        .u_hat(partial1),
        .g_out(right1)
    );

    // ------------------------------------------------------------
    // Step 6: decode u2
    // u2_llr = f(right0, right1)
    // ------------------------------------------------------------
    sc_f_unit #(
        .W(W+1)
    ) u_f_u2 (
        .alpha(right0),
        .beta(right1),
        .f_out(u2_llr)
    );

    assign u2_dec   = u2_llr[W+1];
    assign u_hat[2] = frozen_mask[2] ? 1'b0 : u2_dec;

    // ------------------------------------------------------------
    // Step 7: decode u3
    // u3_llr = g(right0, right1, u2_hat)
    // ------------------------------------------------------------
    sc_g_unit #(
        .W(W+1)
    ) u_g_u3 (
        .alpha(right0),
        .beta(right1),
        .u_hat(u_hat[2]),
        .g_out(u3_llr)
    );

    assign u3_dec   = u3_llr[W+1];
    assign u_hat[3] = frozen_mask[3] ? 1'b0 : u3_dec;

endmodule