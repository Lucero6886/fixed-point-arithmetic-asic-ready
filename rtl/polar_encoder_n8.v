`timescale 1ns/1ps

module polar_encoder_n8 (
    input  wire [7:0] u,
    output wire [7:0] x
);

    wire [7:0] s1;
    wire [7:0] s2;

    // Stage 1: distance = 1
    assign s1[0] = u[0] ^ u[1];
    assign s1[1] = u[1];

    assign s1[2] = u[2] ^ u[3];
    assign s1[3] = u[3];

    assign s1[4] = u[4] ^ u[5];
    assign s1[5] = u[5];

    assign s1[6] = u[6] ^ u[7];
    assign s1[7] = u[7];

    // Stage 2: distance = 2
    assign s2[0] = s1[0] ^ s1[2];
    assign s2[1] = s1[1] ^ s1[3];
    assign s2[2] = s1[2];
    assign s2[3] = s1[3];

    assign s2[4] = s1[4] ^ s1[6];
    assign s2[5] = s1[5] ^ s1[7];
    assign s2[6] = s1[6];
    assign s2[7] = s1[7];

    // Stage 3: distance = 4
    assign x[0] = s2[0] ^ s2[4];
    assign x[1] = s2[1] ^ s2[5];
    assign x[2] = s2[2] ^ s2[6];
    assign x[3] = s2[3] ^ s2[7];

    assign x[4] = s2[4];
    assign x[5] = s2[5];
    assign x[6] = s2[6];
    assign x[7] = s2[7];

endmodule