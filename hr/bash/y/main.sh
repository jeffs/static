#!/usr/bin/env bash
#
# This script works with sparse grids of boolean values.

# Exit immediately on error.  For some reason, this makes HR choke on 'read n'.
# set -euo pipefail

# Allow only Bash builtins, not external commands.
export PATH=

# Set the output height and width per problem description.  See also README.
readonly ROWS=63 COLS=100

function grid-set {
    local -n set_grid=$1
    local -i i=$2 j=$3
    set_grid+=([$i,$j]=1)
}

function grid-get {
    local -n get_grid=$1
    local -i i=$2 j=$3
    if [ ${get_grid[$i,$j]:-0} -eq 1 ]; then
        return 0    # true, because yes, the grid is set at i,j
    else
        return 1    # false, because the grid is empty at i,j
    fi
}

# Appends a single row to the specified grid.  If the grid is empty, adds a row
# having a 1 at index 49.  Otherwise, duplicates the last row of the grid.
function add-stem-row {
    local -n stem_grid=$1
    local -i m=$2   # number of rows already in grid
    if (( m )); then
        # Duplicate the last row.
        local -i j=$COLS
        while (( j-- )); do
            if grid-get stem_grid $((m - 1)) $j; then
                grid-set stem_grid $m $j
            fi
        done
    else
        # Create the first row.
        grid-set stem_grid 0 49
    fi
}

# Appends a single row to the specified grid, extending the arms (upper
# v-shaped part) of each existing Y. The grid must already have at least two
# rows (m >= 2).
function add-arms-row {
    local -n arms_grid=$1
    local -i m=$2       # number of rows already in grid
    local -i j=$COLS
    let lean_right=1    # The first arm (as we scan leftward) leans right.
    while (( j-- )); do
        if grid-get arms_grid $((m - 1)) $j; then
            if grid-get arms_grid $((m - 2)) $j; then
                # Just above the stem.
                grid-set arms_grid $m $((j - 1))
                grid-set arms_grid $m $((j + 1))
            elif grid-get arms_grid $((m - 2)) $((j - 1)); then
                # Right arm.
                grid-set arms_grid $m $((j + 1))
            else
                # Left arm.
                grid-set arms_grid $m $((j - 1))
            fi
        fi
    done
}

function make-grid {
    local -n new_grid=$1
    local -i k=$2   # number of iterations
    local -i m=0    # number of rows in grid so far
    local -i len=32 # segment length (halved at top of loop)
    while (( k-- )); do
        let 'len /= 2'
        local -i i=$len
        for (( ; i--; m++ )); do
            add-stem-row new_grid $m
        done
        for (( i = $len; i--; m++ )); do
            add-arms-row new_grid $m
        done
    done
}

function show-cell {
    local -n cell_grid=$1
    local -i i=$2 j=$3
    echo -n ${cell_grid[$i,$j]:-_}
}

function show-grid {
    local -n show_grid=$1
    local -i i=$ROWS j
    # Print rows last to first, so the first row is shown on the bottom.
    while (( i-- )); do 
        for (( j = 0; j < COLS; ++j )); do
            show-cell show_grid $i $j
        done
        echo
    done
}

function main {
    local n
    read n
    case $n in
        0|1|2|3|4|5)
            local -A grid
            make-grid grid $n
            show-grid grid
            ;;
        *)
            >&2 echo "error: $n: expected 0 <= n <= 5"
            exit 1
            ;;
    esac
}

main
