`timescale 1ns/1ps

module tb_sc_f_unit;

    localparam W = 6;
    localparam integer MIN_VAL = -(1 << (W-1));
    localparam integer MAX_VAL =  (1 << (W-1)) - 1;

    reg signed [W-1:0] alpha;
    reg signed [W-1:0] beta;

    wire signed [W:0] f_out;

    integer ia;
    integer ib;

    integer abs_alpha_exp;
    integer abs_beta_exp;
    integer min_abs_exp;
    integer sign_out_exp;

    reg signed [W:0] expected;

    integer error_count;
    integer test_count;

    sc_f_unit #(
        .W(W)
    ) dut (
        .alpha(alpha),
        .beta(beta),
        .f_out(f_out)
    );

    task check_output;
        begin
            if (f_out !== expected) begin
                $display("FAIL: alpha=%0d beta=%0d | abs_alpha=%0d abs_beta=%0d min_abs=%0d | expected=%0d got=%0d",
                         alpha, beta, abs_alpha_exp, abs_beta_exp, min_abs_exp, expected, f_out);
                error_count = error_count + 1;
            end
            test_count = test_count + 1;
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/sc_f_unit.vcd");
        $dumpvars(0, tb_sc_f_unit);

        error_count = 0;
        test_count  = 0;

        // Exhaustive test for all possible signed W-bit alpha and beta
        for (ia = MIN_VAL; ia <= MAX_VAL; ia = ia + 1) begin
            for (ib = MIN_VAL; ib <= MAX_VAL; ib = ib + 1) begin
                alpha = ia;
                beta  = ib;

                if (ia < 0)
                    abs_alpha_exp = -ia;
                else
                    abs_alpha_exp = ia;

                if (ib < 0)
                    abs_beta_exp = -ib;
                else
                    abs_beta_exp = ib;

                if (abs_alpha_exp <= abs_beta_exp)
                    min_abs_exp = abs_alpha_exp;
                else
                    min_abs_exp = abs_beta_exp;

                sign_out_exp = (ia < 0) ^ (ib < 0);

                if (sign_out_exp)
                    expected = -min_abs_exp;
                else
                    expected =  min_abs_exp;

                #1;
                check_output();
            end
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