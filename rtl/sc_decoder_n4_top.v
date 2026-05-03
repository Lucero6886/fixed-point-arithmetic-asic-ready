`timescale 1ns/1ps

module sc_decoder_n4_top #(
    parameter W = 6
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               en,

    input  wire signed [W-1:0] llr0,
    input  wire signed [W-1:0] llr1,
    input  wire signed [W-1:0] llr2,
    input  wire signed [W-1:0] llr3,

    input  wire        [3:0]   frozen_mask,
    output reg         [3:0]   u_hat
);

    wire [3:0] u_hat_comb;

    sc_decoder_n4 #(
        .W(W)
    ) u_sc_decoder_n4 (
        .llr0(llr0),
        .llr1(llr1),
        .llr2(llr2),
        .llr3(llr3),
        .frozen_mask(frozen_mask),
        .u_hat(u_hat_comb)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            u_hat <= 4'b0000;
        end else if (en) begin
            u_hat <= u_hat_comb;
        end else begin
            u_hat <= u_hat;
        end
    end

endmodule