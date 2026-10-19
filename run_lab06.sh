#!/usr/bin/env bash
# run_lab06.sh : build and run the Lab 06 testbenches, one transcript per question
# Usage: ./run_lab06.sh            (run everything)
#        ./run_lab06.sh --gtkwave  (run everything, then open the VCD files)

LAB_DIR="/ECEN_350_Labs/ECEN350_Labs/lab06"

cd "$LAB_DIR" || { echo "ERROR: cannot cd to $LAB_DIR"; exit 1; }

for tool in iverilog vvp script; do
    command -v "$tool" >/dev/null 2>&1 || { echo "ERROR: $tool not found"; exit 1; }
done

# util-linux script takes -c "cmd"; BSD/macOS script takes the command after the file
if script --version 2>&1 | grep -qi "util-linux"; then
    SCRIPT_STYLE="linux"
else
    SCRIPT_STYLE="bsd"
fi

# run_question <outfile> <dut.v> <tb.v> <binary name>
run_question() {
    local out="$1" dut="$2" tb="$3" bin="$4"

    for f in "$dut" "$tb"; do
        [ -f "$f" ] || { echo "ERROR: missing $f"; return 1; }
    done

    # Commands that get recorded in the transcript
    local cmd="echo '> iverilog -o $bin $dut $tb'; iverilog -o $bin $dut $tb && echo '> vvp $bin' && vvp $bin"

    rm -f "$out"
    if [ "$SCRIPT_STYLE" = "linux" ]; then
        script -q -c "bash -c \"$cmd\"" "$out"
    else
        script -q "$out" bash -c "$cmd"
    fi

    # script leaves carriage returns in the file, strip them
    tr -d '\r' < "$out" > "$out.tmp" && mv "$out.tmp" "$out"

    echo "[$out] $(grep -E 'PASS|FAIL' "$out" | tail -n 1)"
}

echo "Running Lab 06 in $LAB_DIR"
echo

run_question q1.txt SignExtender.v SignExtender_tb.v signext_tb.out
run_question q2.txt ALU.v          ALU_tb.v          alu_tb.out
run_question q3.txt NextPClogic.v  NextPClogic_tb.v  nextpc_tb.out

echo
echo "Transcripts: q1.txt q2.txt q3.txt"
echo "VCD files:"
ls -1 ./*.vcd 2>/dev/null

if [ "$1" = "--gtkwave" ]; then
    command -v gtkwave >/dev/null 2>&1 || { echo "gtkwave not found"; exit 0; }
    for v in SignExtender_tb.vcd ALU_tb.vcd NextPClogic_tb.vcd; do
        [ -f "$v" ] && gtkwave "$v" >/dev/null 2>&1 &
    done
fi
