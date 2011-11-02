#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import httplib
import urllib
from utils import *



#-------------------------------------------------------------------------------
def main(argv):
	
	#test if katello ui is responding
	status = 0
	try:
		conn = httplib.HTTPConnection('localhost', 3000)
		headers = {
			#"User-Agent": "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.13) Gecko/20110103 Fedora/3.6.13-1.fc14 Firefox/3.6.13",
			#"Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
			"Accept-Language": "cs,en-us;q=0.7,en;q=0.3"
			#"Accept-Encoding": "gzip,deflate",
			#"Accept-Charset": "ISO-8859-1,utf-8;q=0.7,*;q=0.7",
			#"Keep-Alive": "115",
			#"Connection": "keep-alive"
			#"Cookie": "rh_omni_tc=70160000000H4AoAAK; s_vi=[CS]v1|26659614851D0899-60000106E02899F9[CE]; _src_session=BAh7CCIQX2NzcmZfdG9rZW4iMXA3NUpXNlJxbjdtVjZzMkdUdmtRcjRZQUJldjZjZ0tQeENUYmJGNjUwL3M9Ig9zZXNzaW9uX2lkIiU3NWQ3ZWE2NzVjNmM3ZWE3NjQ4MTAwMTQxYmQ0OWZmYSILbG9jYWxlIgdjcw%3D%3D--f97422b58b54a3ebf96432bd31ac611512b2bb95",
			#"If-None-Match": "40c74c9e18c5c56ac96ee844a725701b"
			}
		conn.request("GET", "/", None, headers)
		status = conn.getresponse().status
		conn.close()
	except:
		msgFail('katello UI')
		return 1
	
	
	if status == 200:
		msgOK('katello UI')
		return 0
	else:
		msgFail('katello UI')
		return 1
	



#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
