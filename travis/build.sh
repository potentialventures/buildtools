#!/bin/bash
set -ev
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Synthesis build
if [ "${QUARTUS_SYNTHESIS}" = "true" ]; then
    ${DIR}/do_quartus.sh
else
    ${DIR}/do_sim.sh
fi
