`timescale 1ns/1ps

module NextPClogic_tb;

    parameter NUM_RANDOM = 10;    // random data tests per control combination (requirement is 10)

    reg  [63:0] CurrentPC;
    reg  [63:0] SignExtImm64;
    reg         Branch;
    reg         ALUZero;
    reg         Uncondbranch;
    wire [63:0] NextPC;

    integer errors;
    integer tests;
    integer seed;
    integer c;
    integer i;

    NextPClogic dut (
        .NextPC       (NextPC),
        .CurrentPC    (CurrentPC),
        .SignExtImm64 (SignExtImm64),
        .Branch       (Branch),
        .ALUZero      (ALUZero),
        .Uncondbranch (Uncondbranch)
    );

    // Reference model. Written differently from the DUT on purpose: it looks
    // the answer up from the truth table (one case per row) instead of using
    // the expression Uncondbranch | (Branch & ALUZero).
    // ctrl is {Branch, Uncondbranch, ALUZero}
    function [63:0] expected;
        input [63:0] pc;
        input [63:0] imm;
        input [2:0]  ctrl;
        begin
            case (ctrl)
                3'b000:  expected = pc + 64'd4;   // not a branch
                3'b001:  expected = pc + 64'd4;   // not a branch
                3'b010:  expected = pc + imm;     // B, always taken
                3'b011:  expected = pc + imm;     // B, always taken
                3'b100:  expected = pc + 64'd4;   // CBZ, Zero = 0, not taken
                3'b101:  expected = pc + imm;     // CBZ, Zero = 1, taken
                3'b110:  expected = pc + imm;     // both set, Uncondbranch wins
                3'b111:  expected = pc + imm;     // both set, Uncondbranch wins
                default: expected = 64'd0;
            endcase
        end
    endfunction

    // Apply one test vector, wait for the combinational logic, then compare
    task run_test;
        input [63:0] pc;
        input [63:0] imm;
        input [2:0]  ctrl;
        reg   [63:0] expected_out;
        begin
            CurrentPC    = pc;
            SignExtImm64 = imm;
            Branch       = ctrl[2];
            Uncondbranch = ctrl[1];
            ALUZero      = ctrl[0];
            #10;
            expected_out = expected(pc, imm, ctrl);
            tests = tests + 1;
            if (NextPC !== expected_out) begin
                errors = errors + 1;
                $display("ERROR at time %0t: Branch=%b Uncondbranch=%b ALUZero=%b CurrentPC=%h SignExtImm64=%h expected=%h got=%h",
                         $time, ctrl[2], ctrl[1], ctrl[0], pc, imm, expected_out, NextPC);
            end
        end
    endtask

    initial begin
        $dumpfile("NextPClogic_tb.vcd");
        $dumpvars(0, NextPClogic_tb);

        errors = 0;
        tests  = 0;
        seed   = 32'hC0FFEE;

        // Every combination of {Branch, Uncondbranch, ALUZero}
        for (c = 0; c < 8; c = c + 1) begin

            // Directed tests (offsets chosen so the target never equals PC + 4)
            run_test(64'h0000000000001000, 64'h0000000000000020, c[2:0]);  // forward branch
            run_test(64'h0000000000001000, 64'hFFFFFFFFFFFFFFF0, c[2:0]);  // backward branch (-16)
            run_test(64'hFFFFFFFFFFFFFFFC, 64'h0000000000000020, c[2:0]);  // PC wraps past 2^64

            // Random tests: all 64 bits of both data inputs are random
            for (i = 0; i < NUM_RANDOM; i = i + 1)
                run_test({$random(seed), $random(seed)},
                         {$random(seed), $random(seed)}, c[2:0]);
        end

        if (errors == 0)
            $display("PASS: all %0d tests passed.", tests);
        else
            $display("FAIL: %0d of %0d tests failed.", errors, tests);

        $finish;
    end

endmodule