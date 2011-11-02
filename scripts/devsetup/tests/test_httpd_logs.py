#!/usr/bin/env python
# -*- coding: utf-8 -*-


import sys
import os
from utils import *


SECS_RANGE = 600

#-------------------------------------------------------------------------------
def main(argv):
	
	#check log files that they contain no message younger than 5 minutes
	
	#format: "[Sun Feb 13 03:14:01 2011]"
	#checkLogFileTime('/var/log/httpd/ssl_error_log', 1, 25, '%a %b %d %H:%M:%S %Y', SECS_RANGE)
	#checkLogFileTime('/var/log/httpd/error_log',     1, 25, '%a %b %d %H:%M:%S %Y', SECS_RANGE)
	checkLogFile('/var/log/httpd/ssl_error_log')
	checkLogFile('/var/log/httpd/error_log')
	
	return 0

#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
