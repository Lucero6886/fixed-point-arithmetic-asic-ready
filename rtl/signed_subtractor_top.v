`timescale 1ns/1ps

module signed_subtractor_top #(
    parameter W = 6
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               en,
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    output reg  signed [W:0]   y
);

    wire signed [W:0] y_comb;

    signed_subtractor #(
        .W(W)
    ) u_signed_subtractor (
        .a(a),
        .b(b),
        .y(y_comb)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y <= {(W+1){1'b0}};
        end else if (en) begin
            y <= y_comb;
        end else begin
            y <= y;
        end
    end

endmodule