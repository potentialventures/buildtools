#!/bin/bash
set -ev

# Synthesis build
if [ "${QUARTUS_SYNTHESIS}" = "true" ]; then
    ./buildtools/travis/do_quartus.sh
fi

# Simulation build
if [ "${COCOTB_SIMULATION}" = "true" ]; then
    git clone https://github.com/potentialventures/cocotb.git
    export COCOTB=$PWD/cocotb
    cd tb && make
fi
