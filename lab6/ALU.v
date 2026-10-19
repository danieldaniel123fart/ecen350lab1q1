`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111

module ALU(
    output reg [63:0] BusW,
    input      [63:0] BusA,
    input      [63:0] BusB,
    input      [3:0]  ALUCtrl,
    output            Zero
);

    always @(*) begin
        case (ALUCtrl)
            `AND:    BusW = BusA & BusB;   // bitwise AND
            `OR:     BusW = BusA | BusB;   // bitwise OR
            `ADD:    BusW = BusA + BusB;   // addition
            `SUB:    BusW = BusA - BusB;   // subtraction
            `PassB:  BusW = BusB;          // pass B straight through (CBZ)
            default: BusW = 64'b0;         // unused codes, avoids a latch
        endcase
    end

    // Zero is 1 only when every bit of BusW is 0, for any operation
    assign Zero = (BusW == 64'b0);

endmodule