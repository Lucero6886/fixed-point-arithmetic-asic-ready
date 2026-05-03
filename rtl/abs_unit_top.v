`timescale 1ns/1ps

module abs_unit_top #(
    parameter W = 6
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               en,
    input  wire signed [W-1:0] x,
    output reg         [W-1:0] y
);

    wire [W-1:0] y_comb;

    abs_unit #(
        .W(W)
    ) u_abs_unit (
        .x(x),
        .y(y_comb)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y <= {W{1'b0}};
        end else if (en) begin
            y <= y_comb;
        end else begin
            y <= y;
        end
    end

endmodule