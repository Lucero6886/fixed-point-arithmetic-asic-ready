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