.section .data
my_array:       .space  80            // 10 quad words * 8 bytes each = 80 bytes

.section .text
.global lab03c
lab03c:
        // ---- Load address of my_array into X1 ----
        ADRP X1, my_array
        ADD  X1, X1, :lo12:my_array

        // ---- Initialize j = initial_value (first digit of UIN) ----
        ADD  X2, XZR, #<FIRST_DIGIT_OF_UIN>   // X2 = j

        // ---- Initialize loop counter i = 0 ----
        ADD  X0, XZR, XZR                     // X0 = i = 0

LOOP:
        // ---- Check loop condition: i < 10 ----
        SUBS XZR, X0, #10
        B.GE DONE                             // if i >= 10, exit loop

        // ---- my_array[i] = j + j ----
        ADD  X3, X2, X2                       // X3 = j + j
        LSL  X4, X0, #3                       // X4 = i * 8 (byte offset, since quad word = 8 bytes)
        ADD  X5, X1, X4                       // X5 = address of my_array[i]
        STR  X3, [X5]                         // store j+j into my_array[i]

        // ---- j++ ----
        ADD  X2, X2, #1

        // ---- i++ ----
        ADD  X0, X0, #1

        B    LOOP

DONE:
        BR   X30                              // return to caller