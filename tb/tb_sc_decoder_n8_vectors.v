`timescale 1ns/1ps

module tb_sc_decoder_n8_vectors;

    localparam W = 6;

    reg signed [W-1:0] llr0;
    reg signed [W-1:0] llr1;
    reg signed [W-1:0] llr2;
    reg signed [W-1:0] llr3;
    reg signed [W-1:0] llr4;
    reg signed [W-1:0] llr5;
    reg signed [W-1:0] llr6;
    reg signed [W-1:0] llr7;

    reg  [7:0] frozen_mask;
    wire [7:0] u_hat;

    reg  [7:0] expected;

    integer fd;
    integer ret;
    integer line_count;
    integer test_count;
    integer error_count;

    reg [2047:0] header_line;

    integer v_llr0;
    integer v_llr1;
    integer v_llr2;
    integer v_llr3;
    integer v_llr4;
    integer v_llr5;
    integer v_llr6;
    integer v_llr7;

    integer v_frozen0;
    integer v_frozen1;
    integer v_frozen2;
    integer v_frozen3;
    integer v_frozen4;
    integer v_frozen5;
    integer v_frozen6;
    integer v_frozen7;

    integer v_u0;
    integer v_u1;
    integer v_u2;
    integer v_u3;
    integer v_u4;
    integer v_u5;
    integer v_u6;
    integer v_u7;

    integer v_frozen_mask_int;
    integer v_u_hat_int;

    sc_decoder_n8 #(
        .W(W)
    ) dut (
        .llr0(llr0),
        .llr1(llr1),
        .llr2(llr2),
        .llr3(llr3),
        .llr4(llr4),
        .llr5(llr5),
        .llr6(llr6),
        .llr7(llr7),
        .frozen_mask(frozen_mask),
        .u_hat(u_hat)
    );

    task apply_and_check;
        begin
            llr0 = v_llr0;
            llr1 = v_llr1;
            llr2 = v_llr2;
            llr3 = v_llr3;
            llr4 = v_llr4;
            llr5 = v_llr5;
            llr6 = v_llr6;
            llr7 = v_llr7;

            // CSV stores frozen0..frozen7.
            // RTL expects frozen_mask[0] = frozen0, ..., frozen_mask[7] = frozen7.
            frozen_mask = {
                v_frozen7[0],
                v_frozen6[0],
                v_frozen5[0],
                v_frozen4[0],
                v_frozen3[0],
                v_frozen2[0],
                v_frozen1[0],
                v_frozen0[0]
            };

            // CSV stores u_hat0..u_hat7.
            // RTL output u_hat[0] = u_hat0, ..., u_hat[7] = u_hat7.
            expected = {
                v_u7[0],
                v_u6[0],
                v_u5[0],
                v_u4[0],
                v_u3[0],
                v_u2[0],
                v_u1[0],
                v_u0[0]
            };

            #1;

            if (u_hat !== expected) begin
                $display("FAIL line=%0d L=[%0d %0d %0d %0d %0d %0d %0d %0d] mask=%b expected=%b got=%b",
                         line_count,
                         llr0, llr1, llr2, llr3, llr4, llr5, llr6, llr7,
                         frozen_mask, expected, u_hat);
                error_count = error_count + 1;
            end

            test_count = test_count + 1;
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/sc_decoder_n8_vectors.vcd");
        $dumpvars(0, tb_sc_decoder_n8_vectors);

        test_count  = 0;
        error_count = 0;
        line_count  = 0;

        fd = $fopen("tests/golden_vectors/sc_decoder_n8_vectors.csv", "r");

        if (fd == 0) begin
            $display("ERROR: Cannot open tests/golden_vectors/sc_decoder_n8_vectors.csv");
            $finish;
        end

        // Skip header line
        ret = $fgets(header_line, fd);

        while (!$feof(fd)) begin
            ret = $fscanf(fd,
                "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
                v_llr0, v_llr1, v_llr2, v_llr3,
                v_llr4, v_llr5, v_llr6, v_llr7,
                v_frozen0, v_frozen1, v_frozen2, v_frozen3,
                v_frozen4, v_frozen5, v_frozen6, v_frozen7,
                v_u0, v_u1, v_u2, v_u3,
                v_u4, v_u5, v_u6, v_u7,
                v_frozen_mask_int, v_u_hat_int
            );

            line_count = line_count + 1;

            if (ret == 26) begin
                apply_and_check();
            end else if (ret != -1) begin
                $display("WARNING: malformed CSV line around line %0d, fscanf ret=%0d", line_count, ret);
            end
        end

        $fclose(fd);

        $display("====================================");
        $display("Total vector lines read = %0d", line_count);
        $display("Total tests             = %0d", test_count);
        $display("Total errors            = %0d", error_count);

        if (error_count == 0) begin
            $display("ALL TESTS PASSED.");
        end else begin
            $display("TEST FAILED.");
        end

        $display("====================================");

        $finish;
    end

endmodule