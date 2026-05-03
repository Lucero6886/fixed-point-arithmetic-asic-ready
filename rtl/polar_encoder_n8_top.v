`timescale 1ns/1ps

module polar_encoder_n8_top (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    input  wire [7:0] u,
    output reg  [7:0] x
);

    wire [7:0] x_comb;

    polar_encoder_n8 u_polar_encoder_n8 (
        .u(u),
        .x(x_comb)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x <= 8'b0000_0000;
        end else if (en) begin
            x <= x_comb;
        end else begin
            x <= x;
        end
    end

endmodule