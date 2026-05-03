`timescale 1ns/1ps

module sc_g_unit_top #(
    parameter W = 6
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               en,
    input  wire signed [W-1:0] alpha,
    input  wire signed [W-1:0] beta,
    input  wire               u_hat,
    output reg  signed [W:0]   g_out
);

    wire signed [W:0] g_out_comb;

    sc_g_unit #(
        .W(W)
    ) u_sc_g_unit (
        .alpha(alpha),
        .beta(beta),
        .u_hat(u_hat),
        .g_out(g_out_comb)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            g_out <= {(W+1){1'b0}};
        end else if (en) begin
            g_out <= g_out_comb;
        end else begin
            g_out <= g_out;
        end
    end

endmodule