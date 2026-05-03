`timescale 1ns/1ps

module tb_sc_decoder_n4;

    localparam W = 6;

    reg signed [W-1:0] llr0;
    reg signed [W-1:0] llr1;
    reg signed [W-1:0] llr2;
    reg signed [W-1:0] llr3;

    reg [3:0] frozen_mask;
    wire [3:0] u_hat;

    integer l0;
    integer l1;
    integer l2;
    integer l3;
    integer fm;

    reg [3:0] expected;

    integer error_count;
    integer test_count;

    sc_decoder_n4 #(
        .W(W)
    ) dut (
        .llr0(llr0),
        .llr1(llr1),
        .llr2(llr2),
        .llr3(llr3),
        .frozen_mask(frozen_mask),
        .u_hat(u_hat)
    );

    function integer abs_int;
        input integer v;
        begin
            if (v < 0)
                abs_int = -v;
            else
                abs_int = v;
        end
    endfunction

    function integer f_func;
        input integer a;
        input integer b;
        integer aa;
        integer bb;
        integer m;
        begin
            aa = abs_int(a);
            bb = abs_int(b);

            if (aa <= bb)
                m = aa;
            else
                m = bb;

            if ((a < 0) ^ (b < 0))
                f_func = -m;
            else
                f_func = m;
        end
    endfunction

    function integer g_func;
        input integer alpha;
        input integer beta;
        input integer u;
        begin
            if (u == 0)
                g_func = beta + alpha;
            else
                g_func = beta - alpha;
        end
    endfunction

    function integer hard_decision;
        input integer llr;
        begin
            if (llr < 0)
                hard_decision = 1;
            else
                hard_decision = 0;
        end
    endfunction

    function [3:0] golden_sc_decode_n4;
        input integer L0;
        input integer L1;
        input integer L2;
        input integer L3;
        input [3:0] mask;

        integer left0;
        integer left1;
        integer u0_llr;
        integer u1_llr;

        integer partial0;
        integer partial1;

        integer right0;
        integer right1;
        integer u2_llr;
        integer u3_llr;

        reg u0;
        reg u1;
        reg u2;
        reg u3;

        begin
            left0 = f_func(L0, L2);
            left1 = f_func(L1, L3);

            u0_llr = f_func(left0, left1);
            if (mask[0])
                u0 = 1'b0;
            else
                u0 = hard_decision(u0_llr);

            u1_llr = g_func(left0, left1, u0);
            if (mask[1])
                u1 = 1'b0;
            else
                u1 = hard_decision(u1_llr);

            partial0 = u0 ^ u1;
            partial1 = u1;

            right0 = g_func(L0, L2, partial0);
            right1 = g_func(L1, L3, partial1);

            u2_llr = f_func(right0, right1);
            if (mask[2])
                u2 = 1'b0;
            else
                u2 = hard_decision(u2_llr);

            u3_llr = g_func(right0, right1, u2);
            if (mask[3])
                u3 = 1'b0;
            else
                u3 = hard_decision(u3_llr);

            golden_sc_decode_n4 = {u3, u2, u1, u0};
        end
    endfunction

    task check_output;
        begin
            if (u_hat !== expected) begin
                $display("FAIL: L=[%0d %0d %0d %0d] mask=%b expected=%b got=%b",
                         llr0, llr1, llr2, llr3, frozen_mask, expected, u_hat);
                error_count = error_count + 1;
            end

            test_count = test_count + 1;
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/sc_decoder_n4.vcd");
        $dumpvars(0, tb_sc_decoder_n4);

        error_count = 0;
        test_count  = 0;

        // Reduced exhaustive test range for practical simulation:
        // LLR values from -4 to +4 and all frozen masks.
        for (fm = 0; fm < 16; fm = fm + 1) begin
            for (l0 = -4; l0 <= 4; l0 = l0 + 1) begin
                for (l1 = -4; l1 <= 4; l1 = l1 + 1) begin
                    for (l2 = -4; l2 <= 4; l2 = l2 + 1) begin
                        for (l3 = -4; l3 <= 4; l3 = l3 + 1) begin
                            llr0 = l0;
                            llr1 = l1;
                            llr2 = l2;
                            llr3 = l3;
                            frozen_mask = fm[3:0];

                            expected = golden_sc_decode_n4(l0, l1, l2, l3, frozen_mask);

                            #1;
                            check_output();
                        end
                    end
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