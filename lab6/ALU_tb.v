`timescale 1ns/1ps


//Defines
`ifndef AND
`define AND   4'b0000
`endif
`ifndef OR
`define OR    4'b0001
`endif
`ifndef ADD
`define ADD   4'b0010
`endif
`ifndef SUB
`define SUB   4'b0110
`endif
`ifndef PassB
`define PassB 4'b0111
`endif

module ALU_tb;

    parameter NUM_RANDOM = 200;   // random tests per function (requirement is >= 100)
    parameter NUM_FUNCS  = 5;     // AND, OR, ADD, SUB, PassB

    localparam [63:0] ALL0 = 64'h0000000000000000;
    localparam [63:0] ALL1 = 64'hFFFFFFFFFFFFFFFF;

    reg  [63:0] BusA; // inputs 
    reg  [63:0] BusB;
    reg  [3:0]  ALUCtrl;
    wire [63:0] BusW;
    wire        Zero;

    integer errors;
    integer tests;
    integer seed;
    integer f;
    integer i;
    integer ai;
    integer bi;

    // Coverage: how many tests (per function) expected Zero=1 and Zero=0
    integer zero1_count [0:NUM_FUNCS-1];
    integer zero0_count [0:NUM_FUNCS-1];
    ALU dut (
        .BusW    (BusW),
        .BusA    (BusA),
        .BusB    (BusB),
        .ALUCtrl (ALUCtrl),
        .Zero    (Zero)
    );

    // Map a function index (0..4) to its ALUCtrl code
    function [3:0] ctrl_of;
        input integer idx;
        begin
            case (idx)
                0:       ctrl_of = `AND;
                1:       ctrl_of = `OR;
                2:       ctrl_of = `ADD;
                3:       ctrl_of = `SUB;
                4:       ctrl_of = `PassB;
                default: ctrl_of = 4'bxxxx;
            endcase
        end
    endfunction

    // Reference model. Written differently from the DUT on purpose. We will us ethis to check againt the values from the ALU.
    //   AND/OR use De Morgan's laws instead of & and | to use a diffent comp than the same as the component 
    //   ADD uses a 65-bit sum and keeps the low 64 bits to handle overflow
    //   SUB uses two's complement (a + ~b + 1) instead of the - operator same reason as AND/OR
    function [63:0] expected;
        input [63:0] a;
        input [63:0] b;
        input [3:0]  ctrl;
        reg   [64:0] wide_sum;
        begin
            case (ctrl)
                `AND:    expected = ~(~a | ~b);
                `OR:     expected = ~(~a & ~b);
                `ADD:    begin
                             wide_sum = {1'b0, a} + {1'b0, b};
                             expected = wide_sum[63:0];
                         end
                `SUB:    expected = a + (~b) + 64'd1;
                `PassB:  expected = b;
                default: expected = 64'd0;
            endcase
        end
    endfunction

    // Apply one test vector, wait for the combinational logic, then compare
    // both BusW and Zero against the reference model.
    task run_test;
        input [63:0] a;
        input [63:0] b;
        input integer func;
        reg   [3:0]  ctrl;
        reg   [63:0] expected_w;
        reg          expected_z;
        begin
            ctrl    = ctrl_of(func);
            BusA    = a;
            BusB    = b;
            ALUCtrl = ctrl;
            #10;
            expected_w = expected(a, b, ctrl);
            expected_z = (expected_w == 64'd0);
            tests = tests + 1;

            if (expected_z) zero1_count[func] = zero1_count[func] + 1;
            else            zero0_count[func] = zero0_count[func] + 1;

            if ((BusW !== expected_w) || (Zero !== expected_z)) begin
                errors = errors + 1;
                $display("ERROR at time %0t: ALUCtrl=%b A=%h B=%h expected W=%h Z=%b got W=%h Z=%b",
                         $time, ctrl, a, b, expected_w, expected_z, BusW, Zero);
            end
        end
    endtask

    initial begin
        $dumpfile("ALU_tb.vcd");
        $dumpvars(0, ALU_tb);

        errors = 0;
        tests  = 0;
        seed   = 32'hC0FFEE;

        for (f = 0; f < NUM_FUNCS; f = f + 1) begin
            zero1_count[f] = 0;
            zero0_count[f] = 0;
        end

        for (f = 0; f < NUM_FUNCS; f = f + 1) begin

            // All combinations of all zeros / all ones on BusA and BusB
            for (ai = 0; ai < 2; ai = ai + 1)
                for (bi = 0; bi < 2; bi = bi + 1)
                    run_test(ai ? ALL1 : ALL0, bi ? ALL1 : ALL0, f);

            // Directed tests with mixed patterns
            run_test(64'hAAAAAAAAAAAAAAAA, 64'h5555555555555555, f); // AND = 0, OR = all ones
            run_test(64'h0000000000000001, 64'h0000000000000001, f); // equal operands, SUB = 0
            run_test(64'h123456789ABCDEF0, 64'h123456789ABCDEF0, f); // equal operands again
            run_test(64'h8000000000000000, 64'h0000000000000001, f); // top bit vs bottom bit

            // Random tests: all 64 bits of both buses are random
            for (i = 0; i < NUM_RANDOM; i = i + 1)
                run_test({$random(seed), $random(seed)},
                         {$random(seed), $random(seed)}, f);
        end

        // Extra directed tests for ADD and SUB wraparound (func index 2 = ADD, 3 = SUB)
        run_test(ALL1,                 64'd1,                2);  // unsigned overflow: wraps to 0, Zero = 1
        run_test(64'd1,                ALL1,                 2);  // same, operands swapped
        run_test(64'h7FFFFFFFFFFFFFFF, 64'd1,                2);  // signed overflow: becomes 8000...0
        run_test(64'h7FFFFFFFFFFFFFFF, 64'h7FFFFFFFFFFFFFFF, 2);  // signed overflow: becomes FFFF...E
        run_test(64'h8000000000000000, 64'h8000000000000000, 2);  // wraps to 0, Zero = 1
        run_test(ALL0,                 64'd1,                3);  // SUB underflow: becomes all ones
        run_test(64'h8000000000000000, 64'd1,                3);  // SUB: becomes 7FFF...F

        // Confirm every function saw at least one Zero=1 and one Zero=0 case
        for (f = 0; f < NUM_FUNCS; f = f + 1) begin
            if (zero1_count[f] == 0) begin
                errors = errors + 1;
                $display("ERROR: function %0d (ALUCtrl=%b) never tested with Zero=1", f, ctrl_of(f));
            end
            if (zero0_count[f] == 0) begin
                errors = errors + 1;
                $display("ERROR: function %0d (ALUCtrl=%b) never tested with Zero=0", f, ctrl_of(f));
            end
        end

        if (errors == 0)
            $display("PASS: all %0d tests passed.", tests);
        else
            $display("FAIL: %0d errors in %0d tests.", errors, tests);

        $finish;
    end

endmodule
