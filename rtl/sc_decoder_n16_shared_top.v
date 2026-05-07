// Project 8.5: OpenLane top wrapper for SC Decoder N=16 resource-shared RTL
//
// OpenLane top module:
//   sc_decoder_n16_shared_top
//
// Wrapped core:
//   sc_decoder_n16_shared

`timescale 1ns/1ps

module sc_decoder_n16_shared_top (
    input  wire clk,
    input  wire rst_n,
    input  wire start,

    input  wire signed [5:0] llr0,
    input  wire signed [5:0] llr1,
    input  wire signed [5:0] llr2,
    input  wire signed [5:0] llr3,
    input  wire signed [5:0] llr4,
    input  wire signed [5:0] llr5,
    input  wire signed [5:0] llr6,
    input  wire signed [5:0] llr7,
    input  wire signed [5:0] llr8,
    input  wire signed [5:0] llr9,
    input  wire signed [5:0] llr10,
    input  wire signed [5:0] llr11,
    input  wire signed [5:0] llr12,
    input  wire signed [5:0] llr13,
    input  wire signed [5:0] llr14,
    input  wire signed [5:0] llr15,

    input  wire [15:0] frozen_mask,

    output wire [15:0] u_hat,
    output wire        busy,
    output wire        done
);

    sc_decoder_n16_shared #(
        .W_IN(6),
        .W_INT(10)
    ) u_core (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),

        .llr0(llr0),
        .llr1(llr1),
        .llr2(llr2),
        .llr3(llr3),
        .llr4(llr4),
        .llr5(llr5),
        .llr6(llr6),
        .llr7(llr7),
        .llr8(llr8),
        .llr9(llr9),
        .llr10(llr10),
        .llr11(llr11),
        .llr12(llr12),
        .llr13(llr13),
        .llr14(llr14),
        .llr15(llr15),

        .frozen_mask(frozen_mask),

        .u_hat(u_hat),
        .busy(busy),
        .done(done)
    );

endmodule
