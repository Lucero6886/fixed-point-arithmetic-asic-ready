`timescale 1ns/1ps

module abs_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] x,
    output wire        [W-1:0] y
);

    assign y = x[W-1] ? (~x + 1'b1) : x;

endmodule