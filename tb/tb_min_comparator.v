`timescale 1ns/1ps

module tb_min_comparator;

    localparam W = 6;
    localparam integer MAX_VAL = (1 << W) - 1;

    reg  [W-1:0] a;
    reg  [W-1:0] b;
    wire [W-1:0] y;

    integer ia;
    integer ib;
    integer expected;
    integer error_count;
    integer test_count;

    min_comparator #(
        .W(W)
    ) dut (
        .a(a),
        .b(b),
        .y(y)
    );

    task check_output;
        begin
            if (y !== expected[W-1:0]) begin
                $display("FAIL: a=%0d, b=%0d, expected=%0d, got=%0d",
                         a, b, expected, y);
                error_count = error_count + 1;
            end
            test_count = test_count + 1;
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/min_comparator.vcd");
        $dumpvars(0, tb_min_comparator);

        error_count = 0;
        test_count  = 0;

        // Exhaustive test for all possible W-bit unsigned inputs
        for (ia = 0; ia <= MAX_VAL; ia = ia + 1) begin
            for (ib = 0; ib <= MAX_VAL; ib = ib + 1) begin
                a = ia[W-1:0];
                b = ib[W-1:0];

                if (ia <= ib)
                    expected = ia;
                else
                    expected = ib;

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