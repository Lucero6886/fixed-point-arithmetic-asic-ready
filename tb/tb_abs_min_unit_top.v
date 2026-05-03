`timescale 1ns/1ps

module tb_abs_min_unit_top;

    localparam W = 6;

    reg clk;
    reg rst_n;
    reg en;

    reg signed [W-1:0] alpha;
    reg signed [W-1:0] beta;

    wire [W-1:0] min_abs;

    integer abs_alpha_exp;
    integer abs_beta_exp;
    integer expected;
    integer error_count;

    abs_min_unit_top #(
        .W(W)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .alpha(alpha),
        .beta(beta),
        .min_abs(min_abs)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task apply_and_check;
        input signed [W-1:0] ta;
        input signed [W-1:0] tb;
        begin
            alpha = ta;
            beta  = tb;

            if (ta < 0)
                abs_alpha_exp = -ta;
            else
                abs_alpha_exp = ta;

            if (tb < 0)
                abs_beta_exp = -tb;
            else
                abs_beta_exp = tb;

            if (abs_alpha_exp <= abs_beta_exp)
                expected = abs_alpha_exp;
            else
                expected = abs_beta_exp;

            @(posedge clk);
            #1;

            if (min_abs !== expected[W-1:0]) begin
                $display("FAIL at time %0t: alpha=%0d beta=%0d expected=%0d got=%0d",
                         $time, ta, tb, expected, min_abs);
                error_count = error_count + 1;
            end else begin
                $display("PASS at time %0t: alpha=%0d beta=%0d min_abs=%0d",
                         $time, ta, tb, min_abs);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/abs_min_unit_top.vcd");
        $dumpvars(0, tb_abs_min_unit_top);

        error_count = 0;

        rst_n = 0;
        en    = 0;
        alpha = 0;
        beta  = 0;

        #20;
        rst_n = 1;
        en    = 1;

        apply_and_check( 6'sd0,   6'sd0);
        apply_and_check( 6'sd5,  -6'sd3);
        apply_and_check(-6'sd5,   6'sd3);
        apply_and_check( 6'sd31, -6'sd32);
        apply_and_check(-6'sd32,  6'sd31);
        apply_and_check(-6'sd10, -6'sd7);
        apply_and_check( 6'sd20, -6'sd15);
        apply_and_check(-6'sd1,   6'sd0);

        en = 0;
        alpha = -6'sd32;
        beta  =  6'sd0;

        @(posedge clk);
        #1;

        // Since en=0, min_abs should hold previous value
        if (min_abs !== expected[W-1:0]) begin
            $display("FAIL hold test: expected previous min_abs=%0d got=%0d", expected, min_abs);
            error_count = error_count + 1;
        end else begin
            $display("PASS hold test: min_abs holds value %0d", min_abs);
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