// Project 8.2: SC Decoder N=16 Reference RTL Baseline
//
// Purpose:
//   Functionally correct combinational/reference RTL for SC Decoder N=16.
//   This RTL is optimized for correctness and golden-vector verification,
//   not yet for area/timing/resource sharing.
//
// Conventions:
//   - frozen_mask[i] = 1 -> frozen bit, force u_i = 0
//   - frozen_mask[i] = 0 -> information bit
//   - hard decision: LLR < 0 -> 1, otherwise 0
//   - g(a,b,u): b + a if u=0, b - a if u=1
//   - u_hat[0] = u0, LSB-first ordering

`timescale 1ns/1ps

module sc_decoder_n16_ref #(
    parameter W_IN  = 6,
    parameter W_INT = 10
)(
    input  wire signed [W_IN-1:0] llr0,
    input  wire signed [W_IN-1:0] llr1,
    input  wire signed [W_IN-1:0] llr2,
    input  wire signed [W_IN-1:0] llr3,
    input  wire signed [W_IN-1:0] llr4,
    input  wire signed [W_IN-1:0] llr5,
    input  wire signed [W_IN-1:0] llr6,
    input  wire signed [W_IN-1:0] llr7,
    input  wire signed [W_IN-1:0] llr8,
    input  wire signed [W_IN-1:0] llr9,
    input  wire signed [W_IN-1:0] llr10,
    input  wire signed [W_IN-1:0] llr11,
    input  wire signed [W_IN-1:0] llr12,
    input  wire signed [W_IN-1:0] llr13,
    input  wire signed [W_IN-1:0] llr14,
    input  wire signed [W_IN-1:0] llr15,

    input  wire [15:0] frozen_mask,
    output wire [15:0] u_hat
);

    function signed [W_INT-1:0] f_func;
        input signed [W_INT-1:0] a;
        input signed [W_INT-1:0] b;
        reg signed [W_INT-1:0] abs_a;
        reg signed [W_INT-1:0] abs_b;
        reg signed [W_INT-1:0] mag;
        reg negative;
        begin
            abs_a = a[W_INT-1] ? -a : a;
            abs_b = b[W_INT-1] ? -b : b;
            mag = (abs_a < abs_b) ? abs_a : abs_b;
            negative = a[W_INT-1] ^ b[W_INT-1];
            f_func = negative ? -mag : mag;
        end
    endfunction

    function signed [W_INT-1:0] g_func;
        input signed [W_INT-1:0] a;
        input signed [W_INT-1:0] b;
        input u;
        begin
            g_func = (u == 1'b0) ? (b + a) : (b - a);
        end
    endfunction

    wire signed [W_INT-1:0] L0  = {{(W_INT-W_IN){llr0[W_IN-1]}},  llr0};
    wire signed [W_INT-1:0] L1  = {{(W_INT-W_IN){llr1[W_IN-1]}},  llr1};
    wire signed [W_INT-1:0] L2  = {{(W_INT-W_IN){llr2[W_IN-1]}},  llr2};
    wire signed [W_INT-1:0] L3  = {{(W_INT-W_IN){llr3[W_IN-1]}},  llr3};
    wire signed [W_INT-1:0] L4  = {{(W_INT-W_IN){llr4[W_IN-1]}},  llr4};
    wire signed [W_INT-1:0] L5  = {{(W_INT-W_IN){llr5[W_IN-1]}},  llr5};
    wire signed [W_INT-1:0] L6  = {{(W_INT-W_IN){llr6[W_IN-1]}},  llr6};
    wire signed [W_INT-1:0] L7  = {{(W_INT-W_IN){llr7[W_IN-1]}},  llr7};
    wire signed [W_INT-1:0] L8  = {{(W_INT-W_IN){llr8[W_IN-1]}},  llr8};
    wire signed [W_INT-1:0] L9  = {{(W_INT-W_IN){llr9[W_IN-1]}},  llr9};
    wire signed [W_INT-1:0] L10 = {{(W_INT-W_IN){llr10[W_IN-1]}}, llr10};
    wire signed [W_INT-1:0] L11 = {{(W_INT-W_IN){llr11[W_IN-1]}}, llr11};
    wire signed [W_INT-1:0] L12 = {{(W_INT-W_IN){llr12[W_IN-1]}}, llr12};
    wire signed [W_INT-1:0] L13 = {{(W_INT-W_IN){llr13[W_IN-1]}}, llr13};
    wire signed [W_INT-1:0] L14 = {{(W_INT-W_IN){llr14[W_IN-1]}}, llr14};
    wire signed [W_INT-1:0] L15 = {{(W_INT-W_IN){llr15[W_IN-1]}}, llr15};

    wire signed [W_INT-1:0] left0 = f_func(L0, L8);
    wire signed [W_INT-1:0] left1 = f_func(L1, L9);
    wire signed [W_INT-1:0] left2 = f_func(L2, L10);
    wire signed [W_INT-1:0] left3 = f_func(L3, L11);
    wire signed [W_INT-1:0] left4 = f_func(L4, L12);
    wire signed [W_INT-1:0] left5 = f_func(L5, L13);
    wire signed [W_INT-1:0] left6 = f_func(L6, L14);
    wire signed [W_INT-1:0] left7 = f_func(L7, L15);

    wire [7:0] u_left;

    sc_dec_ref_n8 #(.W(W_INT)) u_dec_left_n8 (
        .llr0(left0), .llr1(left1), .llr2(left2), .llr3(left3),
        .llr4(left4), .llr5(left5), .llr6(left6), .llr7(left7),
        .frozen_mask(frozen_mask[7:0]),
        .u_hat(u_left)
    );

    wire p0 = u_left[0] ^ u_left[1] ^ u_left[2] ^ u_left[3] ^
              u_left[4] ^ u_left[5] ^ u_left[6] ^ u_left[7];
    wire p1 = u_left[1] ^ u_left[3] ^ u_left[5] ^ u_left[7];
    wire p2 = u_left[2] ^ u_left[3] ^ u_left[6] ^ u_left[7];
    wire p3 = u_left[3] ^ u_left[7];
    wire p4 = u_left[4] ^ u_left[5] ^ u_left[6] ^ u_left[7];
    wire p5 = u_left[5] ^ u_left[7];
    wire p6 = u_left[6] ^ u_left[7];
    wire p7 = u_left[7];

    wire signed [W_INT-1:0] right0 = g_func(L0, L8,  p0);
    wire signed [W_INT-1:0] right1 = g_func(L1, L9,  p1);
    wire signed [W_INT-1:0] right2 = g_func(L2, L10, p2);
    wire signed [W_INT-1:0] right3 = g_func(L3, L11, p3);
    wire signed [W_INT-1:0] right4 = g_func(L4, L12, p4);
    wire signed [W_INT-1:0] right5 = g_func(L5, L13, p5);
    wire signed [W_INT-1:0] right6 = g_func(L6, L14, p6);
    wire signed [W_INT-1:0] right7 = g_func(L7, L15, p7);

    wire [7:0] u_right;

    sc_dec_ref_n8 #(.W(W_INT)) u_dec_right_n8 (
        .llr0(right0), .llr1(right1), .llr2(right2), .llr3(right3),
        .llr4(right4), .llr5(right5), .llr6(right6), .llr7(right7),
        .frozen_mask(frozen_mask[15:8]),
        .u_hat(u_right)
    );

    assign u_hat[7:0]   = u_left;
    assign u_hat[15:8]  = u_right;

endmodule


module sc_dec_ref_n8 #(
    parameter W = 10
)(
    input  wire signed [W-1:0] llr0,
    input  wire signed [W-1:0] llr1,
    input  wire signed [W-1:0] llr2,
    input  wire signed [W-1:0] llr3,
    input  wire signed [W-1:0] llr4,
    input  wire signed [W-1:0] llr5,
    input  wire signed [W-1:0] llr6,
    input  wire signed [W-1:0] llr7,
    input  wire [7:0] frozen_mask,
    output wire [7:0] u_hat
);

    function signed [W-1:0] f_func;
        input signed [W-1:0] a;
        input signed [W-1:0] b;
        reg signed [W-1:0] abs_a;
        reg signed [W-1:0] abs_b;
        reg signed [W-1:0] mag;
        reg negative;
        begin
            abs_a = a[W-1] ? -a : a;
            abs_b = b[W-1] ? -b : b;
            mag = (abs_a < abs_b) ? abs_a : abs_b;
            negative = a[W-1] ^ b[W-1];
            f_func = negative ? -mag : mag;
        end
    endfunction

    function signed [W-1:0] g_func;
        input signed [W-1:0] a;
        input signed [W-1:0] b;
        input u;
        begin
            g_func = (u == 1'b0) ? (b + a) : (b - a);
        end
    endfunction

    wire signed [W-1:0] left0 = f_func(llr0, llr4);
    wire signed [W-1:0] left1 = f_func(llr1, llr5);
    wire signed [W-1:0] left2 = f_func(llr2, llr6);
    wire signed [W-1:0] left3 = f_func(llr3, llr7);

    wire [3:0] u_left;

    sc_dec_ref_n4 #(.W(W)) u_dec_left_n4 (
        .llr0(left0), .llr1(left1), .llr2(left2), .llr3(left3),
        .frozen_mask(frozen_mask[3:0]),
        .u_hat(u_left)
    );

    wire p0 = u_left[0] ^ u_left[1] ^ u_left[2] ^ u_left[3];
    wire p1 = u_left[1] ^ u_left[3];
    wire p2 = u_left[2] ^ u_left[3];
    wire p3 = u_left[3];

    wire signed [W-1:0] right0 = g_func(llr0, llr4, p0);
    wire signed [W-1:0] right1 = g_func(llr1, llr5, p1);
    wire signed [W-1:0] right2 = g_func(llr2, llr6, p2);
    wire signed [W-1:0] right3 = g_func(llr3, llr7, p3);

    wire [3:0] u_right;

    sc_dec_ref_n4 #(.W(W)) u_dec_right_n4 (
        .llr0(right0), .llr1(right1), .llr2(right2), .llr3(right3),
        .frozen_mask(frozen_mask[7:4]),
        .u_hat(u_right)
    );

    assign u_hat[3:0] = u_left;
    assign u_hat[7:4] = u_right;

endmodule


module sc_dec_ref_n4 #(
    parameter W = 10
)(
    input  wire signed [W-1:0] llr0,
    input  wire signed [W-1:0] llr1,
    input  wire signed [W-1:0] llr2,
    input  wire signed [W-1:0] llr3,
    input  wire [3:0] frozen_mask,
    output wire [3:0] u_hat
);

    function signed [W-1:0] f_func;
        input signed [W-1:0] a;
        input signed [W-1:0] b;
        reg signed [W-1:0] abs_a;
        reg signed [W-1:0] abs_b;
        reg signed [W-1:0] mag;
        reg negative;
        begin
            abs_a = a[W-1] ? -a : a;
            abs_b = b[W-1] ? -b : b;
            mag = (abs_a < abs_b) ? abs_a : abs_b;
            negative = a[W-1] ^ b[W-1];
            f_func = negative ? -mag : mag;
        end
    endfunction

    function signed [W-1:0] g_func;
        input signed [W-1:0] a;
        input signed [W-1:0] b;
        input u;
        begin
            g_func = (u == 1'b0) ? (b + a) : (b - a);
        end
    endfunction

    wire signed [W-1:0] left0 = f_func(llr0, llr2);
    wire signed [W-1:0] left1 = f_func(llr1, llr3);

    wire [1:0] u_left;

    sc_dec_ref_n2 #(.W(W)) u_dec_left_n2 (
        .llr0(left0),
        .llr1(left1),
        .frozen_mask(frozen_mask[1:0]),
        .u_hat(u_left)
    );

    wire p0 = u_left[0] ^ u_left[1];
    wire p1 = u_left[1];

    wire signed [W-1:0] right0 = g_func(llr0, llr2, p0);
    wire signed [W-1:0] right1 = g_func(llr1, llr3, p1);

    wire [1:0] u_right;

    sc_dec_ref_n2 #(.W(W)) u_dec_right_n2 (
        .llr0(right0),
        .llr1(right1),
        .frozen_mask(frozen_mask[3:2]),
        .u_hat(u_right)
    );

    assign u_hat[1:0] = u_left;
    assign u_hat[3:2] = u_right;

endmodule


module sc_dec_ref_n2 #(
    parameter W = 10
)(
    input  wire signed [W-1:0] llr0,
    input  wire signed [W-1:0] llr1,
    input  wire [1:0] frozen_mask,
    output wire [1:0] u_hat
);

    function signed [W-1:0] f_func;
        input signed [W-1:0] a;
        input signed [W-1:0] b;
        reg signed [W-1:0] abs_a;
        reg signed [W-1:0] abs_b;
        reg signed [W-1:0] mag;
        reg negative;
        begin
            abs_a = a[W-1] ? -a : a;
            abs_b = b[W-1] ? -b : b;
            mag = (abs_a < abs_b) ? abs_a : abs_b;
            negative = a[W-1] ^ b[W-1];
            f_func = negative ? -mag : mag;
        end
    endfunction

    function signed [W-1:0] g_func;
        input signed [W-1:0] a;
        input signed [W-1:0] b;
        input u;
        begin
            g_func = (u == 1'b0) ? (b + a) : (b - a);
        end
    endfunction

    function hard_decision;
        input signed [W-1:0] llr;
        begin
            hard_decision = (llr < 0) ? 1'b1 : 1'b0;
        end
    endfunction

    wire signed [W-1:0] left0 = f_func(llr0, llr1);

    wire u0 = frozen_mask[0] ? 1'b0 : hard_decision(left0);

    wire signed [W-1:0] right0 = g_func(llr0, llr1, u0);

    wire u1 = frozen_mask[1] ? 1'b0 : hard_decision(right0);

    assign u_hat[0] = u0;
    assign u_hat[1] = u1;

endmodule