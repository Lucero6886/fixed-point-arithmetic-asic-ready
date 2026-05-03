`timescale 1ns/1ps

module tb_polar_encoder_n8_top;

    reg clk;
    reg rst_n;
    reg en;
    reg [7:0] u;
    wire [7:0] x;

    reg [7:0] expected;
    integer error_count;

    polar_encoder_n8_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .u(u),
        .x(x)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    function [7:0] golden_polar_encode_n8;
        input [7:0] in_u;
        reg [7:0] s1;
        reg [7:0] s2;
        reg [7:0] out_x;
        begin
            s1[0] = in_u[0] ^ in_u[1];
            s1[1] = in_u[1];

            s1[2] = in_u[2] ^ in_u[3];
            s1[3] = in_u[3];

            s1[4] = in_u[4] ^ in_u[5];
            s1[5] = in_u[5];

            s1[6] = in_u[6] ^ in_u[7];
            s1[7] = in_u[7];

            s2[0] = s1[0] ^ s1[2];
            s2[1] = s1[1] ^ s1[3];
            s2[2] = s1[2];
            s2[3] = s1[3];

            s2[4] = s1[4] ^ s1[6];
            s2[5] = s1[5] ^ s1[7];
            s2[6] = s1[6];
            s2[7] = s1[7];

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

    task apply_and_check;
        input [7:0] tu;
        begin
            u = tu;
            expected = golden_polar_encode_n8(tu);

            @(posedge clk);
            #1;

            if (x !== expected) begin
                $display("FAIL at time %0t: u=%b expected=%b got=%b",
                         $time, tu, expected, x);
                error_count = error_count + 1;
            end else begin
                $display("PASS at time %0t: u=%b x=%b",
                         $time, tu, x);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/polar_encoder_n8_top.vcd");
        $dumpvars(0, tb_polar_encoder_n8_top);

        error_count = 0;

        rst_n = 0;
        en    = 0;
        u     = 8'b0;

        #20;
        rst_n = 1;
        en    = 1;

        apply_and_check(8'b0000_0000);
        apply_and_check(8'b0000_0001);
        apply_and_check(8'b0000_1010);
        apply_and_check(8'b1010_1010);
        apply_and_check(8'b1111_0000);
        apply_and_check(8'b1111_1111);
        apply_and_check(8'b0101_0011);

        en = 0;
        u  = 8'b0000_0001;

        @(posedge clk);
        #1;

        // Since en=0, x should hold previous value
        if (x !== expected) begin
            $display("FAIL hold test: expected previous x=%b got=%b", expected, x);
            error_count = error_count + 1;
        end else begin
            $display("PASS hold test: x holds value %b", x);
        end

        if (error_count == 0) begin
            $display("====================================");
            $display("ALL TESTS PASSED.");
            $display("====================================");
        end else begin
            $display("====================================");
            $display("TEST FAILED. Total errors = %0d", error_count);
            $display("====================================");
        end

        $finish;
    end

endmodule