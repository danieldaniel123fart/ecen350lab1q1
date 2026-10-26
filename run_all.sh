#!/usr/bin/env bash
# Build and run every testbench with Icarus Verilog.
# Run from the folder that holds all the .v files:  ./run_all.sh
# Compiled sims go in build/, waveforms (.vcd) go in waves/.

cd "$(dirname "$0")" || exit 1
mkdir -p build waves

fail=0

# run_tb <name> <top module> <filter> <source files...>
# filter = "all" prints everything, "summary" only prints FAIL/ERROR/Done/PASS lines
run_tb()
{
    name="$1"; top="$2"; filter="$3"; shift 3
    echo "=== $name ==="
    if ! iverilog -g2005 -s "$top" -o "build/$name.vvp" "$@"
    then
        echo "COMPILE FAILED: $name"
        fail=1
        echo
        return
    fi
    if [ "$filter" = "summary" ]
    then
        (cd waves && vvp "../build/$name.vvp") | grep -E "FAIL|ERROR|Done|PASS|failed|passed"
    else
        (cd waves && vvp "../build/$name.vvp")
    fi
    echo
}

run_tb alu        ALU_tb              all     ALU.v ALU_tb.v
run_tb signext    SignExtender_tb     all     SignExtender.v SignExtender_tb.v
run_tb nextpc     NextPClogic_tb      all     NextPClogic.v NextPClogic_tb.v
run_tb regfile    tb_RegisterFile     summary RegisterFile.v tb_RegisterFile.v
run_tb mux        tb_mux2to1_8        summary mux2to1_8.v tb_mux2to1_8.v
run_tb control    SC_Control_tb       all     SingleCycleControl.v SC_Control_tb.v
run_tb processor  SingleCycleProcTest_v all   SingleCycleProc.v SingleCycleControl.v ALU.v \
                                              SignExtender.v NextPClogic.v RegisterFile.v \
                                              InstructionMemory.v DataMemory.v SingleCycleProcTest.v

echo "Waveforms in waves/ :"
ls waves/*.vcd 2>/dev/null
echo "Open one with:  gtkwave waves/<file>.vcd"

if [ "$fail" -ne 0 ]
then
    echo "Some builds failed, see messages above."
    exit 1
fi
