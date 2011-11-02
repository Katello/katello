#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import socket
from utils import *


#-------------------------------------------------------------------------------
def main(argv):
	#test if all urls in file /etc/katello/katello.yml are set to localhost
	allUrlsOK = True
	
	hName = socket.gethostname()
	
	try:
		f=open('/etc/katello/katello.yml')
		for line in f.xreadlines():
			#check only lines that start with "url"
			if line.strip().startswith('url:'):
				url = line.split()[1]
				if not (url.find('//localhost') > 0 or url.find('//'+hName) > 0 ):
					allUrlsOK = False
		f.close()
	except:
		msgFail('could not read /etc/katello/katello.yml')
		return 1
	
	if allUrlsOK:
		msgOK('all urls in /etc/katello/katello.yml point to localhost')
		return 0
	else:
		msgFail('/etc/katello/katello.yml url check', 'change urls in the file to localhost')
		return 1



#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
