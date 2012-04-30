#!/usr/bin/python

#name: Example script 2
#apply: katello
#description: Empty python script

import sys

# TODO
print "Test script output"
print "Test script output 2"
sys.stdout.flush()

print >> sys.stderr, "Test script error output"
sys.stderr.flush()

exit(0)