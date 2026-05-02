`timescale 1ns/1ps

module tb_signed_subtractor_top;

    localparam W = 6;

    reg clk;
    reg rst_n;
    reg en;

    reg  signed [W-1:0] a;
    reg  signed [W-1:0] b;
    wire signed [W:0]   y;

    reg signed [W:0] expected;

    integer error_count;

    signed_subtractor_top #(
        .W(W)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task apply_and_check;
        input signed [W-1:0] ta;
        input signed [W-1:0] tb;
        begin
            a = ta;
            b = tb;
            expected = ta - tb;

            @(posedge clk);
            #1;

            if (y !== expected) begin
                $display("FAIL at time %0t: a=%0d b=%0d expected=%0d got=%0d",
                         $time, ta, tb, expected, y);
                error_count = error_count + 1;
            end else begin
                $display("PASS at time %0t: a=%0d b=%0d y=%0d",
                         $time, ta, tb, y);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/signed_subtractor_top.vcd");
        $dumpvars(0, tb_signed_subtractor_top);

        error_count = 0;

        rst_n = 0;
        en    = 0;
        a     = 0;
        b     = 0;

        #20;
        rst_n = 1;
        en    = 1;

        apply_and_check( 6'sd0,   6'sd0);
        apply_and_check( 6'sd5,   6'sd3);
        apply_and_check(-6'sd5,   6'sd3);
        apply_and_check( 6'sd31,  6'sd31);
        apply_and_check(-6'sd32, -6'sd32);
        apply_and_check(-6'sd10, -6'sd7);
        apply_and_check( 6'sd20, -6'sd15);
        apply_and_check( 6'sd31, -6'sd32);
        apply_and_check(-6'sd32,  6'sd31);

        en = 0;
        a  = 6'sd1;
        b  = 6'sd1;

        @(posedge clk);
        #1;

        // Since en=0, y should hold previous value
        if (y !== expected) begin
            $display("FAIL hold test: expected previous y=%0d, got=%0d", expected, y);
            error_count = error_count + 1;
        end else begin
            $display("PASS hold test: y holds value %0d", y);
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