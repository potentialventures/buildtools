#!/bin/bash
#
# Download a Quartus installation, extract and run synthesis
# Required environment variables:
#
#       QUARTUS_LOCATION: URL of a quartus installation
#

set -e
wget -q ${QUARTUS_LOCATION}
mv quartus* quartus_14.0.tar.gz
tar -zxf quartus_14.0.tar.gz
cd syn

PATH=$PWD/../altera/14.0/quartus/bin:$PATH make &
pid=$!

# Long periods with no output so have to force occasional activity
while kill -0 $pid >/dev/null 2>&1; do sleep 5m; echo; done

# Propogate the exit code of make
wait $pid
exit $?
