`timescale 1ns/1ps

module tb_abs_unit;

    localparam W = 6;
    localparam integer MIN_VAL = -(1 << (W-1));
    localparam integer MAX_VAL =  (1 << (W-1)) - 1;

    reg  signed [W-1:0] x;
    wire        [W-1:0] y;

    integer ix;
    integer expected;
    integer error_count;
    integer test_count;

    abs_unit #(
        .W(W)
    ) dut (
        .x(x),
        .y(y)
    );

    task check_output;
        begin
            if (y !== expected[W-1:0]) begin
                $display("FAIL: x=%0d, expected=%0d, got=%0d",
                         x, expected, y);
                error_count = error_count + 1;
            end
            test_count = test_count + 1;
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/abs_unit.vcd");
        $dumpvars(0, tb_abs_unit);

        error_count = 0;
        test_count  = 0;

        for (ix = MIN_VAL; ix <= MAX_VAL; ix = ix + 1) begin
            x = ix;

            if (ix < 0)
                expected = -ix;
            else
                expected = ix;

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