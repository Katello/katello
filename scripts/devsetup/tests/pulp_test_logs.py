#!/usr/bin/env python
# -*- coding: utf-8 -*-


import sys
import os
from utils import *


#-------------------------------------------------------------------------------
def main(argv):
	
	#check all candlepin log files that they contain no message younger than 5 minutes
	#for f in listFiles('/var/log/pulp', '.*log'):
	
	
	#format: "2011-02-03 10:46:00.12
	#checkLogFileTime('/var/log/pulp/client.log',  0, 19, '%Y-%m-%d %H:%M:%S', SECS_RANGE)
	#checkLogFileTime('/var/log/pulp/db.log',      0, 19, '%Y-%m-%d %H:%M:%S', SECS_RANGE)
	#checkLogFileTime('/var/log/pulp/grinder.log', 0, 19, '%Y-%m-%d %H:%M:%S', SECS_RANGE)
	#checkLogFileTime('/var/log/pulp/pulp.log',    0, 19, '%Y-%m-%d %H:%M:%S', SECS_RANGE)
	checkLogFile('/var/log/pulp/client.log')
	checkLogFile('/var/log/pulp/db.log')
	checkLogFile('/var/log/pulp/grinder.log')
	checkLogFile('/var/log/pulp/pulp.log')

	#format: "[2011-02-03 10:06:49.123123]"
	#checkLogFileTime('/var/log/pulp/events.log', 1, 19, '%Y-%m-%d %H:%M:%S', SECS_RANGE)
	checkLogFile('/var/log/pulp/events.log')

	return 0


#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
