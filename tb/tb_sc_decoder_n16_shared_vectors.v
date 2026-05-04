`timescale 1ns/1ps

module tb_sc_decoder_n16_shared_vectors;

    localparam W_IN  = 6;
    localparam W_INT = 10;

    reg clk;
    reg rst_n;
    reg start;

    reg signed [W_IN-1:0] llr0;
    reg signed [W_IN-1:0] llr1;
    reg signed [W_IN-1:0] llr2;
    reg signed [W_IN-1:0] llr3;
    reg signed [W_IN-1:0] llr4;
    reg signed [W_IN-1:0] llr5;
    reg signed [W_IN-1:0] llr6;
    reg signed [W_IN-1:0] llr7;
    reg signed [W_IN-1:0] llr8;
    reg signed [W_IN-1:0] llr9;
    reg signed [W_IN-1:0] llr10;
    reg signed [W_IN-1:0] llr11;
    reg signed [W_IN-1:0] llr12;
    reg signed [W_IN-1:0] llr13;
    reg signed [W_IN-1:0] llr14;
    reg signed [W_IN-1:0] llr15;

    reg [15:0] frozen_mask;

    wire [15:0] u_hat;
    wire busy;
    wire done;

    integer fd;
    integer scan_count;
    integer header_ok;
    reg [4095:0] header_line;

    integer llr_i [0:15];
    integer frozen_i [0:15];
    integer expected_i [0:15];
    integer frozen_mask_int;
    integer expected_u_hat_int;

    reg [15:0] expected_u_hat;

    integer total_lines;
    integer total_tests;
    integer total_errors;
    integer i;
    integer latency_counter;
    integer min_latency;
    integer max_latency;
    integer total_latency;
    integer timeout_counter;

    sc_decoder_n16_shared #(
        .W_IN(W_IN),
        .W_INT(W_INT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),

        .llr0(llr0),
        .llr1(llr1),
        .llr2(llr2),
        .llr3(llr3),
        .llr4(llr4),
        .llr5(llr5),
        .llr6(llr6),
        .llr7(llr7),
        .llr8(llr8),
        .llr9(llr9),
        .llr10(llr10),
        .llr11(llr11),
        .llr12(llr12),
        .llr13(llr13),
        .llr14(llr14),
        .llr15(llr15),

        .frozen_mask(frozen_mask),
        .u_hat(u_hat),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    task build_vectors;
        begin
            llr0  = llr_i[0];
            llr1  = llr_i[1];
            llr2  = llr_i[2];
            llr3  = llr_i[3];
            llr4  = llr_i[4];
            llr5  = llr_i[5];
            llr6  = llr_i[6];
            llr7  = llr_i[7];
            llr8  = llr_i[8];
            llr9  = llr_i[9];
            llr10 = llr_i[10];
            llr11 = llr_i[11];
            llr12 = llr_i[12];
            llr13 = llr_i[13];
            llr14 = llr_i[14];
            llr15 = llr_i[15];

            frozen_mask = 16'd0;
            expected_u_hat = 16'd0;

            for (i = 0; i < 16; i = i + 1) begin
                frozen_mask[i] = frozen_i[i][0];
                expected_u_hat[i] = expected_i[i][0];
            end
        end
    endtask

    task run_one_vector;
        begin
            build_vectors();

            @(negedge clk);
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;

            latency_counter = 0;
            timeout_counter = 0;

            while (done !== 1'b1 && timeout_counter < 1000) begin
                @(posedge clk);
                latency_counter = latency_counter + 1;
                timeout_counter = timeout_counter + 1;
            end

            if (timeout_counter >= 1000) begin
                $display("ERROR: Timeout waiting for done at test %0d", total_tests + 1);
                total_errors = total_errors + 1;
            end else begin
                #1;

                total_latency = total_latency + latency_counter;

                if (latency_counter < min_latency) min_latency = latency_counter;
                if (latency_counter > max_latency) max_latency = latency_counter;

                if (u_hat !== expected_u_hat) begin
                    total_errors = total_errors + 1;

                    if (total_errors <= 20) begin
                        $display("ERROR at vector %0d", total_tests + 1);
                        $display("  latency          = %0d cycles", latency_counter);
                        $display("  frozen_mask      = %b", frozen_mask);
                        $display("  expected_u_hat   = %b (%0d)", expected_u_hat, expected_u_hat_int);
                        $display("  actual_u_hat     = %b (%0d)", u_hat, u_hat);
                        $display("  llr = [%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d]",
                            llr_i[0], llr_i[1], llr_i[2], llr_i[3],
                            llr_i[4], llr_i[5], llr_i[6], llr_i[7],
                            llr_i[8], llr_i[9], llr_i[10], llr_i[11],
                            llr_i[12], llr_i[13], llr_i[14], llr_i[15]);
                    end
                end
            end
        end
    endtask

    initial begin
        $dumpfile("sim/waveforms/sc_decoder_n16_shared_vectors.vcd");
        $dumpvars(0, tb_sc_decoder_n16_shared_vectors);

        clk = 1'b0;
        rst_n = 1'b0;
        start = 1'b0;

        llr0 = 0; llr1 = 0; llr2 = 0; llr3 = 0;
        llr4 = 0; llr5 = 0; llr6 = 0; llr7 = 0;
        llr8 = 0; llr9 = 0; llr10 = 0; llr11 = 0;
        llr12 = 0; llr13 = 0; llr14 = 0; llr15 = 0;
        frozen_mask = 16'd0;

        total_lines = 0;
        total_tests = 0;
        total_errors = 0;

        min_latency = 1000000;
        max_latency = 0;
        total_latency = 0;

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        fd = $fopen("tests/golden_vectors/sc_decoder_n16_vectors.csv", "r");

        if (fd == 0) begin
            $display("ERROR: Cannot open tests/golden_vectors/sc_decoder_n16_vectors.csv");
            $finish;
        end

        header_ok = $fgets(header_line, fd);

        while (!$feof(fd)) begin
            scan_count = $fscanf(fd,
                "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
                llr_i[0], llr_i[1], llr_i[2], llr_i[3],
                llr_i[4], llr_i[5], llr_i[6], llr_i[7],
                llr_i[8], llr_i[9], llr_i[10], llr_i[11],
                llr_i[12], llr_i[13], llr_i[14], llr_i[15],
                frozen_i[0], frozen_i[1], frozen_i[2], frozen_i[3],
                frozen_i[4], frozen_i[5], frozen_i[6], frozen_i[7],
                frozen_i[8], frozen_i[9], frozen_i[10], frozen_i[11],
                frozen_i[12], frozen_i[13], frozen_i[14], frozen_i[15],
                expected_i[0], expected_i[1], expected_i[2], expected_i[3],
                expected_i[4], expected_i[5], expected_i[6], expected_i[7],
                expected_i[8], expected_i[9], expected_i[10], expected_i[11],
                expected_i[12], expected_i[13], expected_i[14], expected_i[15],
                frozen_mask_int, expected_u_hat_int
            );

            if (scan_count == 50) begin
                total_lines = total_lines + 1;

                run_one_vector();

                total_tests = total_tests + 1;
            end
        end

        $fclose(fd);

        $display("====================================");
        $display("Total vector lines read = %0d", total_lines);
        $display("Total tests             = %0d", total_tests);
        $display("Total errors            = %0d", total_errors);

        if (total_tests > 0) begin
            $display("Latency min cycles      = %0d", min_latency);
            $display("Latency max cycles      = %0d", max_latency);
            $display("Latency avg cycles      = %0d", total_latency / total_tests);
        end

        if (total_errors == 0) begin
            $display("ALL TESTS PASSED.");
        end else begin
            $display("TEST FAILED.");
        end

        $display("====================================");
        $finish;
    end

endmodule