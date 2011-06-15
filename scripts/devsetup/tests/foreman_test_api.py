#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import simplejson
from utils import *


#-------------------------------------------------------------------------------
def main(argv):
	#test if katello api is responding
	
	p = os.popen('curl -k http://localhost:3001/dashboard?format=json 2> /dev/null')
	response = p.readline()
	p.close()
	
	try:
		simplejson.loads(response)
		msgOK('foreman rest api')
		return 0
	except:
		msgFail('foreman rest api is not responding')
		return 1



#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
