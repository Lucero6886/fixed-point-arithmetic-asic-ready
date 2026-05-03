`timescale 1ns/1ps

module tb_abs_unit_top;

    localparam W = 6;

    reg clk;
    reg rst_n;
    reg en;

    reg signed [W-1:0] x;
    wire       [W-1:0] y;

    integer expected;
    integer error_count;

    abs_unit_top #(
        .W(W)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .x(x),
        .y(y)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task apply_and_check;
        input signed [W-1:0] tx;
        begin
            x = tx;

            if (tx < 0)
                expected = -tx;
            else
                expected = tx;

            @(posedge clk);
            #1;

            if (y !== expected[W-1:0]) begin
                $display("FAIL at time %0t: x=%0d expected=%0d got=%0d",
                         $time, tx, expected, y);
                error_count = error_count + 1;
            end else begin
                $display("PASS at time %0t: x=%0d y=%0d",
                         $time, tx, y);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/abs_unit_top.vcd");
        $dumpvars(0, tb_abs_unit_top);

        error_count = 0;

        rst_n = 0;
        en    = 0;
        x     = 0;

        #20;
        rst_n = 1;
        en    = 1;

        apply_and_check( 6'sd0);
        apply_and_check( 6'sd1);
        apply_and_check(-6'sd1);
        apply_and_check( 6'sd15);
        apply_and_check(-6'sd15);
        apply_and_check( 6'sd31);
        apply_and_check(-6'sd32);

        en = 0;
        x  = -6'sd5;

        @(posedge clk);
        #1;

        // Since en=0, y should hold previous value
        if (y !== expected[W-1:0]) begin
            $display("FAIL hold test: expected previous y=%0d got=%0d", expected, y);
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