#!/bin/bash
#
# Download the simulator and run a simulation
#
#       SIM_LOCATION URL of a quartus installation
#

set -e
wget -O sim.tar.gz ${SIM_LOCATION}
tar -zxf sim.tar.gz
export PATH=`pwd`/sim/bin:$PATH
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ "${VUNIT_FUSESOC_SIMULATION}" = "true" ]; then
    ${DIR}/../funit/funit.py -x results.xml
fi

if [ "${COCOTB_SIMULATION}" = "true" ]; then
    make
fi

# Generate HMAC digest and post the results back to The Open Corps
MSG_DIGEST=`openssl dgst -hex -sha1 -hmac $MSG_TOKEN results.xml | awk '{print $2}'`

# NB Let's Encrypt CA isn't in the curl bundle on Trusty
curl -k -H "X-Hub-Signature:sha1=${MSG_DIGEST}" -H "Content-Type:application/xml" -H "Travis-Commit:${TRAVIS_COMMIT}" -H "Travis-JobID:${TRAVIS_JOB_ID}" -H "Travis-BuildID:${TRAVIS_BUILD_ID}" --data-binary @results.xml https://theopencorps.potential.ventures/${REPOSITORY}/simulation/results

