`timescale 1ns/1ps

module sc_decoder_n8_top #(
    parameter W = 6
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               en,

    input  wire signed [W-1:0] llr0,
    input  wire signed [W-1:0] llr1,
    input  wire signed [W-1:0] llr2,
    input  wire signed [W-1:0] llr3,
    input  wire signed [W-1:0] llr4,
    input  wire signed [W-1:0] llr5,
    input  wire signed [W-1:0] llr6,
    input  wire signed [W-1:0] llr7,

    input  wire        [7:0]   frozen_mask,
    output reg         [7:0]   u_hat
);

    reg signed [W-1:0] llr0_r;
    reg signed [W-1:0] llr1_r;
    reg signed [W-1:0] llr2_r;
    reg signed [W-1:0] llr3_r;
    reg signed [W-1:0] llr4_r;
    reg signed [W-1:0] llr5_r;
    reg signed [W-1:0] llr6_r;
    reg signed [W-1:0] llr7_r;

    reg [7:0] frozen_mask_r;

    wire [7:0] u_hat_comb;

    sc_decoder_n8 #(
        .W(W)
    ) u_sc_decoder_n8 (
        .llr0(llr0_r),
        .llr1(llr1_r),
        .llr2(llr2_r),
        .llr3(llr3_r),
        .llr4(llr4_r),
        .llr5(llr5_r),
        .llr6(llr6_r),
        .llr7(llr7_r),
        .frozen_mask(frozen_mask_r),
        .u_hat(u_hat_comb)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            llr0_r <= {W{1'b0}};
            llr1_r <= {W{1'b0}};
            llr2_r <= {W{1'b0}};
            llr3_r <= {W{1'b0}};
            llr4_r <= {W{1'b0}};
            llr5_r <= {W{1'b0}};
            llr6_r <= {W{1'b0}};
            llr7_r <= {W{1'b0}};

            frozen_mask_r <= 8'b0000_0000;
            u_hat <= 8'b0000_0000;
        end else if (en) begin
            llr0_r <= llr0;
            llr1_r <= llr1;
            llr2_r <= llr2;
            llr3_r <= llr3;
            llr4_r <= llr4;
            llr5_r <= llr5;
            llr6_r <= llr6;
            llr7_r <= llr7;

            frozen_mask_r <= frozen_mask;

            // This captures the decoder output corresponding to
            // the previously registered LLR/frozen-mask inputs.
            u_hat <= u_hat_comb;
        end else begin
            llr0_r <= llr0_r;
            llr1_r <= llr1_r;
            llr2_r <= llr2_r;
            llr3_r <= llr3_r;
            llr4_r <= llr4_r;
            llr5_r <= llr5_r;
            llr6_r <= llr6_r;
            llr7_r <= llr7_r;

            frozen_mask_r <= frozen_mask_r;
            u_hat <= u_hat;
        end
    end

endmodule
