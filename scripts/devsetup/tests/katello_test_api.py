#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import simplejson
from utils import *


#-------------------------------------------------------------------------------
def main(argv):
	#test if katello api is responding
	
	p = os.popen('curl -k http://localhost:3000/api/organizations/ 2> /dev/null')
	response = p.readline()
	p.close()
	
	try:
		simplejson.loads(response)
		msgOK('katello rest api')
		return 0
	except:
		msgFail('katello rest api is not responding')
		return 1



#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
