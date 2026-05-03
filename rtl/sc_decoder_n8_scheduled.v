`timescale 1ns/1ps

module sc_decoder_n8_scheduled #(
    parameter W    = 6,
    parameter LLRW = 10
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               start,

    input  wire signed [W-1:0] llr0,
    input  wire signed [W-1:0] llr1,
    input  wire signed [W-1:0] llr2,
    input  wire signed [W-1:0] llr3,
    input  wire signed [W-1:0] llr4,
    input  wire signed [W-1:0] llr5,
    input  wire signed [W-1:0] llr6,
    input  wire signed [W-1:0] llr7,

    input  wire        [7:0]   frozen_mask,

    output reg         [7:0]   u_hat,
    output reg                 busy,
    output reg                 done
);

    // ------------------------------------------------------------
    // State encoding
    // ------------------------------------------------------------
    localparam S_IDLE     = 6'd0;

    localparam S_LEFT0    = 6'd1;
    localparam S_LEFT1    = 6'd2;
    localparam S_LEFT2    = 6'd3;
    localparam S_LEFT3    = 6'd4;

    localparam S_L_A0     = 6'd5;
    localparam S_L_A1     = 6'd6;
    localparam S_L_U0     = 6'd7;
    localparam S_L_U1     = 6'd8;
    localparam S_L_R0     = 6'd9;
    localparam S_L_R1     = 6'd10;
    localparam S_L_U2     = 6'd11;
    localparam S_L_U3     = 6'd12;

    localparam S_RIGHT0   = 6'd13;
    localparam S_RIGHT1   = 6'd14;
    localparam S_RIGHT2   = 6'd15;
    localparam S_RIGHT3   = 6'd16;

    localparam S_R_A0     = 6'd17;
    localparam S_R_A1     = 6'd18;
    localparam S_R_U0     = 6'd19;
    localparam S_R_U1     = 6'd20;
    localparam S_R_R0     = 6'd21;
    localparam S_R_R1     = 6'd22;
    localparam S_R_U2     = 6'd23;
    localparam S_R_U3     = 6'd24;

    localparam S_DONE     = 6'd25;

    reg [5:0] state;

    // ------------------------------------------------------------
    // Internal storage
    // ------------------------------------------------------------
    reg signed [LLRW-1:0] L0;
    reg signed [LLRW-1:0] L1;
    reg signed [LLRW-1:0] L2;
    reg signed [LLRW-1:0] L3;
    reg signed [LLRW-1:0] L4;
    reg signed [LLRW-1:0] L5;
    reg signed [LLRW-1:0] L6;
    reg signed [LLRW-1:0] L7;

    reg [7:0] mask_r;

    reg signed [LLRW-1:0] left0;
    reg signed [LLRW-1:0] left1;
    reg signed [LLRW-1:0] left2;
    reg signed [LLRW-1:0] left3;

    reg signed [LLRW-1:0] right0;
    reg signed [LLRW-1:0] right1;
    reg signed [LLRW-1:0] right2;
    reg signed [LLRW-1:0] right3;

    reg signed [LLRW-1:0] a0;
    reg signed [LLRW-1:0] a1;
    reg signed [LLRW-1:0] r0;
    reg signed [LLRW-1:0] r1;

    reg u0;
    reg u1;
    reg u2;
    reg u3;
    reg u4;
    reg u5;
    reg u6;
    reg u7;

    reg p0;
    reg p1;
    reg p2;
    reg p3;

    // ------------------------------------------------------------
    // Sign extension
    // ------------------------------------------------------------
    function signed [LLRW-1:0] sext_input;
        input signed [W-1:0] v;
        begin
            sext_input = {{(LLRW-W){v[W-1]}}, v};
        end
    endfunction

    // ------------------------------------------------------------
    // Absolute magnitude
    // ------------------------------------------------------------
    function [LLRW-1:0] abs_mag;
        input signed [LLRW-1:0] v;
        begin
            if (v < 0)
                abs_mag = -v;
            else
                abs_mag = v;
        end
    endfunction

    // ------------------------------------------------------------
    // SC f function: min-sum approximation
    // ------------------------------------------------------------
    function signed [LLRW-1:0] f_func;
        input signed [LLRW-1:0] a;
        input signed [LLRW-1:0] b;
        reg [LLRW-1:0] aa;
        reg [LLRW-1:0] bb;
        reg [LLRW-1:0] mm;
        begin
            aa = abs_mag(a);
            bb = abs_mag(b);

            if (aa <= bb)
                mm = aa;
            else
                mm = bb;

            if (a[LLRW-1] ^ b[LLRW-1])
                f_func = -$signed(mm);
            else
                f_func = $signed(mm);
        end
    endfunction

    // ------------------------------------------------------------
    // SC g function
    // ------------------------------------------------------------
    function signed [LLRW-1:0] g_func;
        input signed [LLRW-1:0] alpha;
        input signed [LLRW-1:0] beta;
        input u_decision;
        begin
            if (u_decision == 1'b0)
                g_func = beta + alpha;
            else
                g_func = beta - alpha;
        end
    endfunction

    // ------------------------------------------------------------
    // Hard decision
    // ------------------------------------------------------------
    function hard_decision;
        input signed [LLRW-1:0] llr;
        begin
            hard_decision = (llr < 0) ? 1'b1 : 1'b0;
        end
    endfunction

    // ------------------------------------------------------------
    // FSM
    // ------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            busy  <= 1'b0;
            done  <= 1'b0;
            u_hat <= 8'b0000_0000;

            L0 <= 0; L1 <= 0; L2 <= 0; L3 <= 0;
            L4 <= 0; L5 <= 0; L6 <= 0; L7 <= 0;

            mask_r <= 8'b0;

            left0 <= 0; left1 <= 0; left2 <= 0; left3 <= 0;
            right0 <= 0; right1 <= 0; right2 <= 0; right3 <= 0;

            a0 <= 0; a1 <= 0; r0 <= 0; r1 <= 0;

            u0 <= 0; u1 <= 0; u2 <= 0; u3 <= 0;
            u4 <= 0; u5 <= 0; u6 <= 0; u7 <= 0;

            p0 <= 0; p1 <= 0; p2 <= 0; p3 <= 0;
        end else begin
            done <= 1'b0;

            case (state)
                S_IDLE: begin
                    busy <= 1'b0;

                    if (start) begin
                        L0 <= sext_input(llr0);
                        L1 <= sext_input(llr1);
                        L2 <= sext_input(llr2);
                        L3 <= sext_input(llr3);
                        L4 <= sext_input(llr4);
                        L5 <= sext_input(llr5);
                        L6 <= sext_input(llr6);
                        L7 <= sext_input(llr7);

                        mask_r <= frozen_mask;

                        u_hat <= 8'b0000_0000;

                        busy  <= 1'b1;
                        state <= S_LEFT0;
                    end
                end

                // ------------------------------------------------
                // N=8 left LLRs
                // ------------------------------------------------
                S_LEFT0: begin
                    left0 <= f_func(L0, L4);
                    state <= S_LEFT1;
                end

                S_LEFT1: begin
                    left1 <= f_func(L1, L5);
                    state <= S_LEFT2;
                end

                S_LEFT2: begin
                    left2 <= f_func(L2, L6);
                    state <= S_LEFT3;
                end

                S_LEFT3: begin
                    left3 <= f_func(L3, L7);
                    state <= S_L_A0;
                end

                // ------------------------------------------------
                // Decode left N=4: u0,u1,u2,u3
                // ------------------------------------------------
                S_L_A0: begin
                    a0 <= f_func(left0, left2);
                    state <= S_L_A1;
                end

                S_L_A1: begin
                    a1 <= f_func(left1, left3);
                    state <= S_L_U0;
                end

                S_L_U0: begin
                    if (mask_r[0])
                        u0 <= 1'b0;
                    else
                        u0 <= hard_decision(f_func(a0, a1));
                    state <= S_L_U1;
                end

                S_L_U1: begin
                    if (mask_r[1])
                        u1 <= 1'b0;
                    else
                        u1 <= hard_decision(g_func(a0, a1, u0));
                    state <= S_L_R0;
                end

                S_L_R0: begin
                    r0 <= g_func(left0, left2, u0 ^ u1);
                    state <= S_L_R1;
                end

                S_L_R1: begin
                    r1 <= g_func(left1, left3, u1);
                    state <= S_L_U2;
                end

                S_L_U2: begin
                    if (mask_r[2])
                        u2 <= 1'b0;
                    else
                        u2 <= hard_decision(f_func(r0, r1));
                    state <= S_L_U3;
                end

                S_L_U3: begin
                    if (mask_r[3])
                        u3 <= 1'b0;
                    else
                        u3 <= hard_decision(g_func(r0, r1, u2));

                    state <= S_RIGHT0;
                end

                // ------------------------------------------------
                // Compute N=4 partial sums for left branch
                // partial = polar_encode_n4(u0,u1,u2,u3)
                //
                // p0 = u0 ^ u1 ^ u2 ^ u3
                // p1 = u1 ^ u3
                // p2 = u2 ^ u3
                // p3 = u3
                // ------------------------------------------------
                S_RIGHT0: begin
                    p0 <= u0 ^ u1 ^ u2 ^ u3;
                    p1 <= u1 ^ u3;
                    p2 <= u2 ^ u3;
                    p3 <= u3;

                    right0 <= g_func(L0, L4, u0 ^ u1 ^ u2 ^ u3);
                    state <= S_RIGHT1;
                end

                S_RIGHT1: begin
                    right1 <= g_func(L1, L5, p1);
                    state <= S_RIGHT2;
                end

                S_RIGHT2: begin
                    right2 <= g_func(L2, L6, p2);
                    state <= S_RIGHT3;
                end

                S_RIGHT3: begin
                    right3 <= g_func(L3, L7, p3);
                    state <= S_R_A0;
                end

                // ------------------------------------------------
                // Decode right N=4: u4,u5,u6,u7
                // ------------------------------------------------
                S_R_A0: begin
                    a0 <= f_func(right0, right2);
                    state <= S_R_A1;
                end

                S_R_A1: begin
                    a1 <= f_func(right1, right3);
                    state <= S_R_U0;
                end

                S_R_U0: begin
                    if (mask_r[4])
                        u4 <= 1'b0;
                    else
                        u4 <= hard_decision(f_func(a0, a1));
                    state <= S_R_U1;
                end

                S_R_U1: begin
                    if (mask_r[5])
                        u5 <= 1'b0;
                    else
                        u5 <= hard_decision(g_func(a0, a1, u4));
                    state <= S_R_R0;
                end

                S_R_R0: begin
                    r0 <= g_func(right0, right2, u4 ^ u5);
                    state <= S_R_R1;
                end

                S_R_R1: begin
                    r1 <= g_func(right1, right3, u5);
                    state <= S_R_U2;
                end

                S_R_U2: begin
                    if (mask_r[6])
                        u6 <= 1'b0;
                    else
                        u6 <= hard_decision(f_func(r0, r1));
                    state <= S_R_U3;
                end

                S_R_U3: begin
                    if (mask_r[7])
                        u7 <= 1'b0;
                    else
                        u7 <= hard_decision(g_func(r0, r1, u6));

                    state <= S_DONE;
                end

                S_DONE: begin
                    u_hat[0] <= u0;
                    u_hat[1] <= u1;
                    u_hat[2] <= u2;
                    u_hat[3] <= u3;
                    u_hat[4] <= u4;
                    u_hat[5] <= u5;
                    u_hat[6] <= u6;
                    u_hat[7] <= u7;

                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= S_IDLE;
                end

                default: begin
                    state <= S_IDLE;
                    busy  <= 1'b0;
                    done  <= 1'b0;
                end
            endcase
        end
    end

endmodule