`timescale 1ns/1ps

module tb_min_comparator_top;

    localparam W = 6;

    reg clk;
    reg rst_n;
    reg en;

    reg  [W-1:0] a;
    reg  [W-1:0] b;
    wire [W-1:0] y;

    integer expected;
    integer error_count;

    min_comparator_top #(
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
        input [W-1:0] ta;
        input [W-1:0] tb;
        begin
            a = ta;
            b = tb;

            if (ta <= tb)
                expected = ta;
            else
                expected = tb;

            @(posedge clk);
            #1;

            if (y !== expected[W-1:0]) begin
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
        $dumpfile("sim/waveforms/min_comparator_top.vcd");
        $dumpvars(0, tb_min_comparator_top);

        error_count = 0;

        rst_n = 0;
        en    = 0;
        a     = 0;
        b     = 0;

        #20;
        rst_n = 1;
        en    = 1;

        apply_and_check(6'd0,  6'd0);
        apply_and_check(6'd1,  6'd2);
        apply_and_check(6'd2,  6'd1);
        apply_and_check(6'd15, 6'd31);
        apply_and_check(6'd31, 6'd15);
        apply_and_check(6'd63, 6'd0);
        apply_and_check(6'd0,  6'd63);
        apply_and_check(6'd32, 6'd32);

        en = 0;
        a  = 6'd1;
        b  = 6'd0;

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