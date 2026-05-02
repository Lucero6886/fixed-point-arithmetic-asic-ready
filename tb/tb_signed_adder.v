`timescale 1ns/1ps

module tb_signed_adder;

    localparam W = 6;
    localparam MIN_VAL = -(1 << (W-1));
    localparam MAX_VAL =  (1 << (W-1)) - 1;

    reg  signed [W-1:0] a;
    reg  signed [W-1:0] b;
    wire signed [W:0]   y;

    reg  signed [W:0] expected;

    integer ia;
    integer ib;
    integer error_count;
    integer test_count;

    signed_adder #(
        .W(W)
    ) dut (
        .a(a),
        .b(b),
        .y(y)
    );

    task check_output;
        begin
            if (y !== expected) begin
                $display("FAIL: a=%0d, b=%0d, expected=%0d, got=%0d",
                         a, b, expected, y);
                error_count = error_count + 1;
            end
            test_count = test_count + 1;
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/signed_adder.vcd");
        $dumpvars(0, tb_signed_adder);

        error_count = 0;
        test_count  = 0;

        // Exhaustive test for all possible W-bit signed inputs
        for (ia = MIN_VAL; ia <= MAX_VAL; ia = ia + 1) begin
            for (ib = MIN_VAL; ib <= MAX_VAL; ib = ib + 1) begin
                a = ia;
                b = ib;
                expected = ia + ib;
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