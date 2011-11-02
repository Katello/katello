#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import simplejson
from utils import *


#-------------------------------------------------------------------------------
def main(argv):
	
	#test if pulp api returns correct json data
	
	p = os.popen('curl -k -u admin:admin https://localhost/pulp/api/repositories/ 2> /dev/null')
	response = p.readline()
	p.close()
	
	try:
		simplejson.loads(response)
		msgOK('pulp rest api')
		return 0
	except:
		msgFail('pulp rest api is not responding')
		return 1
	



#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
