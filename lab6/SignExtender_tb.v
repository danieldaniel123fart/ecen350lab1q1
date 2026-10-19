`timescale 1ns/1ps

`ifndef Itype
`define Itype   2'b00
`endif
`ifndef Dtype
`define Dtype   2'b01
`endif
`ifndef CBtype
`define CBtype  2'b10
`endif
`ifndef Btype
`define Btype   2'b11
`endif

module SignExtender_tb;

    parameter NUM_RANDOM = 200;   // random tests per SignOp (requirement is >= 100)

    reg  [25:0] Instruction;
    reg  [1:0]  SignOp;
    wire [63:0] SignExOut;

    integer errors;
    integer tests;
    integer seed;
    integer op;
    integer i;

    SignExtender dut (
        .SignExOut   (SignExOut),
        .Instruction (Instruction),
        .SignOp      (SignOp)
    );

    // Reference model. Written differently from the DUT on purpose: it uses
    // signed variables and an arithmetic shift instead of concatenation, so the
    // same mistake is unlikely to appear in both.
    function [63:0] expected;
        input [25:0] instr;
        input [1:0]  sop;
        reg signed [8:0]  d_imm;
        reg signed [18:0] cb_imm;
        reg signed [25:0] b_imm;
        reg signed [63:0] wide;
        begin
            case (sop)
                `Itype: begin
                    expected = 64'd0 + instr[21:10];     // zero extend
                end
                `Dtype: begin
                    d_imm    = instr[20:12];
                    wide     = d_imm;                    // signed assign sign-extends
                    expected = wide;
                end
                `CBtype: begin
                    cb_imm   = instr[23:5];
                    wide     = cb_imm;
                    wide     = wide <<< 2;               // shift left by 2
                    expected = wide;
                end
                `Btype: begin
                    b_imm    = instr[25:0];
                    wide     = b_imm;
                    wide     = wide <<< 2;
                    expected = wide;
                end
                default: expected = 64'd0;
            endcase
        end
    endfunction

    // Apply one test vector, wait for the combinational logic, then compare
    task run_test;
        input [25:0] instr;
        input [1:0]  sop;
        reg   [63:0] expected_out;
        begin
            Instruction  = instr;
            SignOp       = sop;
            #10;
            expected_out = expected(instr, sop);
            tests = tests + 1;
            if (SignExOut !== expected_out) begin
                errors = errors + 1;
                $display("ERROR at time %0t: SignOp=%b Instruction=%h expected=%h got=%h",
                         $time, sop, instr, expected_out, SignExOut);
            end
        end
    endtask

    initial begin
        $dumpfile("SignExtender_tb.vcd");
        $dumpvars(0, SignExtender_tb);

        errors = 0;
        tests  = 0;
        seed   = 32'hC0FFEE;

        for (op = 0; op < 4; op = op + 1) begin
            // Directed corner cases
            run_test(26'h0000000, op[1:0]);   // all zeros
            run_test(26'h3FFFFFF, op[1:0]);   // all ones
            run_test(26'h2000000, op[1:0]);   // only bit 25 set
            run_test(26'h1FFFFFF, op[1:0]);   // bit 25 clear, rest set

            // Random tests
            for (i = 0; i < NUM_RANDOM; i = i + 1) begin
                run_test($random(seed), op[1:0]);   // low 26 bits are used
            end
        end

        if (errors == 0)
            $display("PASS: all %0d tests passed.", tests);
        else
            $display("FAIL: %0d of %0d tests failed.", errors, tests);

        $finish;
    end

endmodule