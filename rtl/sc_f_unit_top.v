`timescale 1ns/1ps

module sc_f_unit_top #(
    parameter W = 6
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               en,
    input  wire signed [W-1:0] alpha,
    input  wire signed [W-1:0] beta,
    output reg  signed [W:0]   f_out
);

    wire signed [W:0] f_out_comb;

    sc_f_unit #(
        .W(W)
    ) u_sc_f_unit (
        .alpha(alpha),
        .beta(beta),
        .f_out(f_out_comb)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            f_out <= {(W+1){1'b0}};
        end else if (en) begin
            f_out <= f_out_comb;
        end else begin
            f_out <= f_out;
        end
    end

endmodule