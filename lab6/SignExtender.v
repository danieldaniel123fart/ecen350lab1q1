`define Itype   2'b00
`define Dtype   2'b01
`define CBtype  2'b10
`define Btype   2'b11

module SignExtender(
    output reg [63:0] SignExOut,
    input      [25:0] Instruction,
    input      [1:0]  SignOp
);

    always @(*) begin
        case (SignOp)
            // I-Type: 12-bit immediate, zero-extended
            `Itype:  SignExOut = {52'b0, Instruction[21:10]};

            // D-Type: 9-bit address, sign-extended
            `Dtype:  SignExOut = {{55{Instruction[20]}}, Instruction[20:12]};

            // CB-Type: 19-bit address, sign-extended, shifted left 2
            `CBtype: SignExOut = {{43{Instruction[23]}}, Instruction[23:5], 2'b00};

            // B-Type: 26-bit address, sign-extended, shifted left 2
            `Btype:  SignExOut = {{36{Instruction[25]}}, Instruction[25:0], 2'b00};

            // Covers all cases, so no latch is inferred
            default: SignExOut = 64'b0;
        endcase
    end

endmodule