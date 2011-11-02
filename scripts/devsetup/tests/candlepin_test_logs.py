#!/usr/bin/env python
# -*- coding: utf-8 -*-


import sys
import os
from utils import *


#-------------------------------------------------------------------------------
def main(argv):
	
	
	#check all candlepin log files that they contain no message younger than 5 minutes
	for f in listFiles('/var/log/candlepin', '.*log'):
		#checkLogFileTime(f, 0, 28, '%a %b %d %H:%M:%S %Z %Y', SECS_RANGE)
		checkLogFile(f)

	#format: "Feb 14 08:33:10"	
	#checkLogFileTime('/var/log/tomcat6/catalina.out', 0, 15, '%b %d %H:%M:%S', SECS_RANGE)
	checkLogFile('/var/log/tomcat6/catalina.out')

	return 0


#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
