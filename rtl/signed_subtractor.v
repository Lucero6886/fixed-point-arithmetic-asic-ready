`timescale 1ns/1ps

module signed_subtractor #(
    parameter W = 6
)(
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    output wire signed [W:0]   y
);

    wire signed [W:0] a_ext;
    wire signed [W:0] b_ext;

    assign a_ext = {a[W-1], a};
    assign b_ext = {b[W-1], b};

    assign y = a_ext - b_ext;

endmodule