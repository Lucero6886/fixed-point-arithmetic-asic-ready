`timescale 1ns/1ps

module tb_polar_encoder_n8;

    reg  [7:0] u;
    wire [7:0] x;

    reg [7:0] expected;

    integer iu;
    integer error_count;
    integer test_count;

    polar_encoder_n8 dut (
        .u(u),
        .x(x)
    );

    function [7:0] golden_polar_encode_n8;
        input [7:0] in_u;
        reg [7:0] s1;
        reg [7:0] s2;
        reg [7:0] out_x;
        begin
            // Stage 1
            s1[0] = in_u[0] ^ in_u[1];
            s1[1] = in_u[1];

            s1[2] = in_u[2] ^ in_u[3];
            s1[3] = in_u[3];

            s1[4] = in_u[4] ^ in_u[5];
            s1[5] = in_u[5];

            s1[6] = in_u[6] ^ in_u[7];
            s1[7] = in_u[7];

            // Stage 2
            s2[0] = s1[0] ^ s1[2];
            s2[1] = s1[1] ^ s1[3];
            s2[2] = s1[2];
            s2[3] = s1[3];

            s2[4] = s1[4] ^ s1[6];
            s2[5] = s1[5] ^ s1[7];
            s2[6] = s1[6];
            s2[7] = s1[7];

            // Stage 3
            out_x[0] = s2[0] ^ s2[4];
            out_x[1] = s2[1] ^ s2[5];
            out_x[2] = s2[2] ^ s2[6];
            out_x[3] = s2[3] ^ s2[7];

            out_x[4] = s2[4];
            out_x[5] = s2[5];
            out_x[6] = s2[6];
            out_x[7] = s2[7];

            golden_polar_encode_n8 = out_x;
        end
    endfunction

    task check_output;
        begin
            if (x !== expected) begin
                $display("FAIL: u=%b expected=%b got=%b", u, expected, x);
                error_count = error_count + 1;
            end
            test_count = test_count + 1;
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/polar_encoder_n8.vcd");
        $dumpvars(0, tb_polar_encoder_n8);

        error_count = 0;
        test_count  = 0;

        // Exhaustive test for all 8-bit input vectors
        for (iu = 0; iu < 256; iu = iu + 1) begin
            u = iu[7:0];
            expected = golden_polar_encode_n8(u);
            #1;
            check_output();
        end

        $display("====================================");
        $display("Total tests  = %0d", test_count);
        $display("Total errors = %0d", error_count);

        if (error_count == 0) begin
            $display("ALL TESTS PASSED.");
        end else begin
            $display("TEST FAILED.");
        end

        $display("====================================");

        $finish;
    end

endmodule