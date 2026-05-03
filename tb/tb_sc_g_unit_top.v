`timescale 1ns/1ps

module tb_sc_g_unit_top;

    localparam W = 6;

    reg clk;
    reg rst_n;
    reg en;

    reg signed [W-1:0] alpha;
    reg signed [W-1:0] beta;
    reg                u_hat;

    wire signed [W:0] g_out;

    reg signed [W:0] expected;

    integer error_count;

    sc_g_unit_top #(
        .W(W)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .alpha(alpha),
        .beta(beta),
        .u_hat(u_hat),
        .g_out(g_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task apply_and_check;
        input signed [W-1:0] ta;
        input signed [W-1:0] tb;
        input                tu;
        begin
            alpha = ta;
            beta  = tb;
            u_hat = tu;

            if (tu == 1'b0)
                expected = tb + ta;
            else
                expected = tb - ta;

            @(posedge clk);
            #1;

            if (g_out !== expected) begin
                $display("FAIL at time %0t: alpha=%0d beta=%0d u_hat=%0d expected=%0d got=%0d",
                         $time, ta, tb, tu, expected, g_out);
                error_count = error_count + 1;
            end else begin
                $display("PASS at time %0t: alpha=%0d beta=%0d u_hat=%0d g_out=%0d",
                         $time, ta, tb, tu, g_out);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/sc_g_unit_top.vcd");
        $dumpvars(0, tb_sc_g_unit_top);

        error_count = 0;

        rst_n = 0;
        en    = 0;
        alpha = 0;
        beta  = 0;
        u_hat = 0;

        #20;
        rst_n = 1;
        en    = 1;

        apply_and_check( 6'sd0,   6'sd0,  1'b0);
        apply_and_check( 6'sd5,   6'sd3,  1'b0);
        apply_and_check( 6'sd5,   6'sd3,  1'b1);
        apply_and_check(-6'sd5,   6'sd3,  1'b0);
        apply_and_check(-6'sd5,   6'sd3,  1'b1);
        apply_and_check( 6'sd31, -6'sd32, 1'b0);
        apply_and_check( 6'sd31, -6'sd32, 1'b1);
        apply_and_check(-6'sd32, -6'sd32, 1'b0);
        apply_and_check(-6'sd32, -6'sd32, 1'b1);

        en = 0;
        alpha = 6'sd1;
        beta  = 6'sd1;
        u_hat = 1'b0;

        @(posedge clk);
        #1;

        // Since en=0, g_out should hold previous value
        if (g_out !== expected) begin
            $display("FAIL hold test: expected previous g_out=%0d got=%0d", expected, g_out);
            error_count = error_count + 1;
        end else begin
            $display("PASS hold test: g_out holds value %0d", g_out);
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