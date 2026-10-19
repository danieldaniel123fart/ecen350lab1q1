module NextPClogic(
    output reg [63:0] NextPC,
    input  [63:0] CurrentPC,
    input  [63:0] SignExtImm64,
    input         Branch,
    input         ALUZero,
    input         Uncondbranch
);

    // Mux select from the truth table: taken if B, or CBZ with Zero set
    wire take_branch;
    assign take_branch = Uncondbranch | (Branch & ALUZero);

    always @(*) begin
        if (take_branch)
            NextPC = CurrentPC + SignExtImm64;   // offset already shifted by the sign extender
        else
            NextPC = CurrentPC + 64'd4;          // next sequential instruction
    end

endmodule