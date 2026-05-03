`timescale 1ns/1ps

module tb_sc_g_unit;

    localparam W = 6;
    localparam integer MIN_VAL = -(1 << (W-1));
    localparam integer MAX_VAL =  (1 << (W-1)) - 1;

    reg signed [W-1:0] alpha;
    reg signed [W-1:0] beta;
    reg                u_hat;

    wire signed [W:0] g_out;

    integer ia;
    integer ib;
    integer iu;

    reg signed [W:0] expected;

    integer error_count;
    integer test_count;

    sc_g_unit #(
        .W(W)
    ) dut (
        .alpha(alpha),
        .beta(beta),
        .u_hat(u_hat),
        .g_out(g_out)
    );

    task check_output;
        begin
            if (g_out !== expected) begin
                $display("FAIL: alpha=%0d beta=%0d u_hat=%0d expected=%0d got=%0d",
                         alpha, beta, u_hat, expected, g_out);
                error_count = error_count + 1;
            end
            test_count = test_count + 1;
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/sc_g_unit.vcd");
        $dumpvars(0, tb_sc_g_unit);

        error_count = 0;
        test_count  = 0;

        // Exhaustive test:
        // alpha: 64 values
        // beta : 64 values
        // u_hat: 2 values
        for (ia = MIN_VAL; ia <= MAX_VAL; ia = ia + 1) begin
            for (ib = MIN_VAL; ib <= MAX_VAL; ib = ib + 1) begin
                for (iu = 0; iu <= 1; iu = iu + 1) begin
                    alpha = ia;
                    beta  = ib;
                    u_hat = iu[0];

                    if (iu == 0)
                        expected = ib + ia;
                    else
                        expected = ib - ia;

                    #1;
                    check_output();
                end
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