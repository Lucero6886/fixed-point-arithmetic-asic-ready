`timescale 1ns/1ps

module tb_sc_decoder_n4_top;

    localparam W = 6;

    reg clk;
    reg rst_n;
    reg en;

    reg signed [W-1:0] llr0;
    reg signed [W-1:0] llr1;
    reg signed [W-1:0] llr2;
    reg signed [W-1:0] llr3;

    reg  [3:0] frozen_mask;
    wire [3:0] u_hat;

    reg [3:0] expected;
    integer error_count;

    sc_decoder_n4_top #(
        .W(W)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .llr0(llr0),
        .llr1(llr1),
        .llr2(llr2),
        .llr3(llr3),
        .frozen_mask(frozen_mask),
        .u_hat(u_hat)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

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
            u0 = mask[0] ? 1'b0 : hard_decision(u0_llr);

            u1_llr = g_func(left0, left1, u0);
            u1 = mask[1] ? 1'b0 : hard_decision(u1_llr);

            partial0 = u0 ^ u1;
            partial1 = u1;

            right0 = g_func(L0, L2, partial0);
            right1 = g_func(L1, L3, partial1);

            u2_llr = f_func(right0, right1);
            u2 = mask[2] ? 1'b0 : hard_decision(u2_llr);

            u3_llr = g_func(right0, right1, u2);
            u3 = mask[3] ? 1'b0 : hard_decision(u3_llr);

            golden_sc_decode_n4 = {u3, u2, u1, u0};
        end
    endfunction

    task apply_and_check;
        input integer L0;
        input integer L1;
        input integer L2;
        input integer L3;
        input [3:0] mask;
        begin
            llr0 = L0;
            llr1 = L1;
            llr2 = L2;
            llr3 = L3;
            frozen_mask = mask;

            expected = golden_sc_decode_n4(L0, L1, L2, L3, mask);

            @(posedge clk);
            #1;

            if (u_hat !== expected) begin
                $display("FAIL at time %0t: L=[%0d %0d %0d %0d] mask=%b expected=%b got=%b",
                         $time, L0, L1, L2, L3, mask, expected, u_hat);
                error_count = error_count + 1;
            end else begin
                $display("PASS at time %0t: L=[%0d %0d %0d %0d] mask=%b u_hat=%b",
                         $time, L0, L1, L2, L3, mask, u_hat);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/sc_decoder_n4_top.vcd");
        $dumpvars(0, tb_sc_decoder_n4_top);

        error_count = 0;

        rst_n = 0;
        en = 0;
        llr0 = 0;
        llr1 = 0;
        llr2 = 0;
        llr3 = 0;
        frozen_mask = 4'b1111;

        #20;
        rst_n = 1;
        en = 1;

        apply_and_check( 4,  3,  2,  1, 4'b0000);
        apply_and_check(-4,  3,  2, -1, 4'b0000);
        apply_and_check( 4, -3, -2,  1, 4'b0011);
        apply_and_check(-4, -3,  2,  1, 4'b0011);
        apply_and_check( 1, -2,  3, -4, 4'b0101);
        apply_and_check(-1,  2, -3,  4, 4'b1010);
        apply_and_check( 0,  0,  0,  0, 4'b1111);

        en = 0;
        llr0 = -6'sd4;
        llr1 = -6'sd4;
        llr2 = -6'sd4;
        llr3 = -6'sd4;
        frozen_mask = 4'b0000;

        @(posedge clk);
        #1;

        if (u_hat !== expected) begin
            $display("FAIL hold test: expected previous u_hat=%b got=%b", expected, u_hat);
            error_count = error_count + 1;
        end else begin
            $display("PASS hold test: u_hat holds value %b", u_hat);
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