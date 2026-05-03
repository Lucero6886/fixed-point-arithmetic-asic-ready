`timescale 1ns/1ps

module tb_sc_f_unit_top;

    localparam W = 6;

    reg clk;
    reg rst_n;
    reg en;

    reg signed [W-1:0] alpha;
    reg signed [W-1:0] beta;

    wire signed [W:0] f_out;

    integer abs_alpha_exp;
    integer abs_beta_exp;
    integer min_abs_exp;
    integer sign_out_exp;

    reg signed [W:0] expected;

    integer error_count;

    sc_f_unit_top #(
        .W(W)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .alpha(alpha),
        .beta(beta),
        .f_out(f_out)
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
                min_abs_exp = abs_alpha_exp;
            else
                min_abs_exp = abs_beta_exp;

            sign_out_exp = (ta < 0) ^ (tb < 0);

            if (sign_out_exp)
                expected = -min_abs_exp;
            else
                expected =  min_abs_exp;

            @(posedge clk);
            #1;

            if (f_out !== expected) begin
                $display("FAIL at time %0t: alpha=%0d beta=%0d expected=%0d got=%0d",
                         $time, ta, tb, expected, f_out);
                error_count = error_count + 1;
            end else begin
                $display("PASS at time %0t: alpha=%0d beta=%0d f_out=%0d",
                         $time, ta, tb, f_out);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/sc_f_unit_top.vcd");
        $dumpvars(0, tb_sc_f_unit_top);

        error_count = 0;

        rst_n = 0;
        en    = 0;
        alpha = 0;
        beta  = 0;

        #20;
        rst_n = 1;
        en    = 1;

        apply_and_check( 6'sd0,   6'sd0);
        apply_and_check( 6'sd5,   6'sd3);
        apply_and_check(-6'sd5,   6'sd3);
        apply_and_check( 6'sd31, -6'sd32);
        apply_and_check(-6'sd32,  6'sd31);
        apply_and_check(-6'sd10, -6'sd7);
        apply_and_check( 6'sd20, -6'sd15);
        apply_and_check(-6'sd1,   6'sd0);
        apply_and_check(-6'sd32, -6'sd32);

        en = 0;
        alpha = -6'sd32;
        beta  =  6'sd0;

        @(posedge clk);
        #1;

        // Since en=0, f_out should hold previous value
        if (f_out !== expected) begin
            $display("FAIL hold test: expected previous f_out=%0d got=%0d", expected, f_out);
            error_count = error_count + 1;
        end else begin
            $display("PASS hold test: f_out holds value %0d", f_out);
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