`timescale 1ns/1ps

module sc_decoder_n8_shared_top (
    input  wire              clk,
    input  wire              rst_n,
    input  wire              start,

    input  wire signed [5:0] llr0,
    input  wire signed [5:0] llr1,
    input  wire signed [5:0] llr2,
    input  wire signed [5:0] llr3,
    input  wire signed [5:0] llr4,
    input  wire signed [5:0] llr5,
    input  wire signed [5:0] llr6,
    input  wire signed [5:0] llr7,

    input  wire        [7:0] frozen_mask,

    output wire        [7:0] u_hat,
    output wire              busy,
    output wire              done
);

    sc_decoder_n8_shared #(
        .W(6),
        .LLRW(10)
    ) u_decoder (
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

        .frozen_mask(frozen_mask),

        .u_hat(u_hat),
        .busy(busy),
        .done(done)
    );

endmodule