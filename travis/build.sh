#!/bin/bash
set -ev
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Synthesis build
if [ "${QUARTUS_SYNTHESIS}" = "true" ]; then
    ${DIR}/do_quartus.sh
fi

# Simulation build
if [ "${COCOTB_SIMULATION}" = "true" ]; then
    git clone https://github.com/potentialventures/cocotb.git
    export COCOTB=$PWD/cocotb
    cd tb && make
fi
