.section .data
UIN:    .quad   <SUM_OF_UIN_DIGITS>   // replace with the sum of your UIN's digits

.section .text
.global lab03b
lab03b:
        // ---- Load address of UIN into a register ----
        ADRP X1, UIN                  // load page address of UIN
        ADD  X1, X1, :lo12:UIN        // add low 12 bits to get full address

        // ---- Load current value of UIN into X2 ----
        LDR  X2, [X1]                 // X2 = UIN

        // ---- Initialize loop counter i = 0 in X0 ----
        ADD  X0, XZR, XZR             // X0 = i = 0

LOOP:
        // ---- Check loop condition: i <= 5 ----
        SUBS XZR, X0, #5              // compare i - 5
        B.GT DONE                     // if i > 5, exit loop (condition i<=5 false)

        // ---- Loop body: UIN = UIN + 1 ----
        ADD  X2, X2, #1               // UIN++ (in register)
        STR  X2, [X1]                 // store updated UIN back to memory

        // ---- i++ ----
        ADD  X0, X0, #1               // i++

        B    LOOP                     // repeat

DONE:
        BR   X30                      // return to caller