`timescale 1ns/1ps

module min_comparator #(
    parameter W = 6
)(
    input  wire [W-1:0] a,
    input  wire [W-1:0] b,
    output wire [W-1:0] y
);

    assign y = (a <= b) ? a : b;

endmodule