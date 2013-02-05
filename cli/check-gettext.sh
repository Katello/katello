#!/bin/bash

grep -inr "_(\(.*\(%[sdr]\)\)\{2,\}" src/katello/client | grep -vin "#dont_check_gettext"

exit_code=`grep -inr "_(\(.*\(%[sdr]\)\)\{2,\}" src/katello/client | grep -vin "#dont_check_gettext" | wc -l`
echo
echo "Number of hits: $exit_code"
echo
exit $exit_code

