#!/bin/bash
#
# Download the simulator and run a simulation
#
#       SIM_LOCATION URL of a quartus installation
#

set -e
wget --quiet -O sim.tar.gz ${SIM_LOCATION}
tar -zxf sim.tar.gz
export PATH=`pwd`/sim/bin:$PATH
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ "${VUNIT_FUSESOC_SIMULATION}" = "true" ]; then
    ${DIR}/../funit/funit.py -x results.xml --exit-0 | tee simulation.log
fi

if [ "${VUNIT_SIMULATION}" = "true" ]; then
    for vunit_script in ${VUNIT_SCRIPTFILES}; do
        cd `dirname $vunit_script` && $vunit_script -x results.xml --exit-0 | tee -a ~/simulation.log
    done
fi


if [ "${COCOTB_SIMULATION}" = "true" ]; then
    make
fi

cd
${DIR}/../junit/combine.py combined_results.xml

# Generate HMAC digest and post the results back to The Open Corps
# NB Let's Encrypt CA isn't in the curl bundle on Trusty
MSG_DIGEST=`openssl dgst -hex -sha1 -hmac $MSG_TOKEN combined_results.xml | awk '{print $2}'`
curl -k -H "X-Hub-Signature:sha1=${MSG_DIGEST}" -H "Content-Type:application/xml" -H "Travis-Commit:${TRAVIS_COMMIT}" -H "Travis-JobID:${TRAVIS_JOB_ID}" -H "Travis-BuildID:${TRAVIS_BUILD_ID}" --data-binary @combined_results.xml https://theopencorps.potential.ventures/${REPOSITORY}/simulation/results

MSG_DIGEST=`openssl dgst -hex -sha1 -hmac $MSG_TOKEN simulation.log | awk '{print $2}'`
curl -k -H "X-Hub-Signature:sha1=${MSG_DIGEST}" -H "Content-Type:application/xml" -H "Travis-Commit:${TRAVIS_COMMIT}" -H "Travis-JobID:${TRAVIS_JOB_ID}" -H "Travis-BuildID:${TRAVIS_BUILD_ID}" -H "Content-Filename:simulation.log" --data-binary @simulation.log https://theopencorps.potential.ventures/${REPOSITORY}/simulation/log

