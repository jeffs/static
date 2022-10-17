#!/usr/bin/env zsh

set -euo pipefail

declare -i i

for i in {0..5}; do
    echo -n "TEST $i: "
    if ! diff -q <(./main.sh <<< $i 2>/dev/null) gold$i >& /dev/null; then
        echo FAIL
    else
        echo PASS
    fi
done
