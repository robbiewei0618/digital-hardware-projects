#!/usr/bin/env bash
# legacy_run.sh NAME PASS_REGEX FAIL_REGEX RUNDIR -- <iverilog args...>
#
# Compiles and runs one course testbench with Icarus Verilog inside RUNDIR
# (so relative data paths in the testbench resolve), then decides PASS/FAIL
# from the log: PASS_REGEX must appear and FAIL_REGEX (may be "") must not.
# Prints one summary line:  LEGACY <NAME> PASS|FAIL
set -uo pipefail
name=$1 pass=$2 fail=$3 rundir=$4; shift 4
[ "${1:-}" = "--" ] && shift
logdir=$(pwd)/build/legacy; mkdir -p "$logdir"
log=$logdir/$name.log
( cd "$rundir" && iverilog -g2012 -o "$logdir/$name.vvp" "$@" && timeout ${LEGACY_TIMEOUT:-900} vvp -n "$logdir/$name.vvp" ) > "$log" 2>&1
rc=$?
status=PASS
[ $rc -ne 0 ] && status=FAIL
grep -Eq -- "$pass" "$log" || status=FAIL
if [ -n "$fail" ] && grep -Eq -- "$fail" "$log"; then status=FAIL; fi
echo "LEGACY $name $status"
[ $status = PASS ]
